/// <reference path="../pb_data/types.d.ts" />

/**
 * Ticket Generation Hook
 * 
 * Trigger: onRecordAfterUpdateSuccess (event_bookings)
 * Condition: payment_status BECOMES 'paid'
 * Action:
 * 1. Verify if tickets already exist (Idempotency)
 * 2. Parse 'metadata' (Cart items)
 * 3. Loop items -> Generate 'event_booking_tickets'
 * 4. Update 'events.last_ticket_seq'
 * 5. Update 'event_tickets.sold'
 */

onModelAfterUpdate((e) => {
    // -----------------------------------------------------------------
    // 1. FILTER: Only "event_bookings"
    // -----------------------------------------------------------------
    // e.model can be any model. We need to check if it belongs to 'event_bookings' collection.
    // In PBJS, models usually have .collection() method if they are records.
    try {
        if (e.model.collection().name !== "event_bookings") {
            return;
        }
    } catch (err) {
        // Not a record model or collection not found
        return;
    }

    // -----------------------------------------------------------------
    // 2. CONDITION: payment_status BECOMES 'paid'
    // -----------------------------------------------------------------
    // We only care if the NEW state is 'paid'
    if (e.model.getString("payment_status") !== "paid") return;

    console.log(`[Hook] 🎫 processing ticket generation for Booking ${e.model.getId()}...`);

    try {
        const bookingId = e.model.getId();
        const eventId = e.model.getString("event");

        // -----------------------------------------------------------------
        // 3. Idempotency Check
        // -----------------------------------------------------------------
        // Check if we already have tickets for this booking
        const existingTickets = $app.findRecordsByFilter(
            "event_booking_tickets",
            `booking = '${bookingId}'`,
            "-created",
            1
        );

        if (existingTickets.length > 0) {
            console.log(`[Hook] ⚠️ Tickets already exist for booking ${bookingId}. Skipping generation.`);
            return;
        }

        // -----------------------------------------------------------------
        // 4. Parse Metadata (Cart)
        // -----------------------------------------------------------------
        // metadata format: [{ "ticket_type_id": "xyz", "quantity": 2, "options": {...} }]
        // On server-side model update, get("metadata") might return the object directly or string.
        const metadata = e.model.get("metadata");

        let items = [];
        if (typeof metadata === 'string') {
            try { items = JSON.parse(metadata); } catch (e) { }
        } else if (Array.isArray(metadata)) {
            items = metadata;
        }

        if (!items || items.length === 0) {
            console.warn(`[Hook] ⚠️ No items in metadata for booking ${bookingId}.`);
            return;
        }

        // -----------------------------------------------------------------
        // 5. Prepare Event & sequences
        // -----------------------------------------------------------------
        const event = $app.findRecordById("events", eventId);
        let eventLastSeq = event.getInt("last_ticket_seq") || 0;

        const ticketFormat = event.getString("ticket_id_format") || "TIX-{CODE}-{SEQ}";
        const eventCode = event.getString("code") || "EVT";

        // -----------------------------------------------------------------
        // 6. Generate Tickets
        // -----------------------------------------------------------------
        $app.runInTransaction((txApp) => {
            const bookingsTicketsCollection = txApp.findCollectionByNameOrId("event_booking_tickets");

            items.forEach(item => {
                const ticketTypeId = item.ticket_type_id;
                const qty = parseInt(item.quantity);
                const options = item.options || {}; // JSON object

                if (!ticketTypeId || qty <= 0) return;

                // Update 'sold' count for this ticket type
                try {
                    const ticketTypeRecord = txApp.findRecordById("event_tickets", ticketTypeId);
                    const currentSold = ticketTypeRecord.getInt("sold");
                    ticketTypeRecord.set("sold", currentSold + qty);
                    txApp.save(ticketTypeRecord);
                } catch (err) {
                    console.error(`[Hook] ❌ Failed to update sold count for ticket ${ticketTypeId}: ${err.message}`);
                    throw err; // Propagate error to rollback transaction
                }

                // Create individual tickets
                for (let i = 0; i < qty; i++) {
                    eventLastSeq++;

                    const seqStr = eventLastSeq.toString().padStart(4, "0"); // 0001
                    // Generate Ticket ID
                    // e.g., TIX-REUNI26-0001, TIX-REUNI26-0002
                    const ticketIdStr = ticketFormat
                        .replace("{CODE}", eventCode)
                        .replace("{SEQ}", seqStr);

                    const newTicket = new Record(bookingsTicketsCollection);
                    newTicket.set("ticket_id", ticketIdStr);
                    newTicket.set("booking", bookingId);
                    newTicket.set("ticket_type", ticketTypeId);
                    newTicket.set("selected_options", options);
                    newTicket.set("shirt_picked_up", false);
                    newTicket.set("checked_in", false);

                    txApp.save(newTicket);
                    console.log(`[Hook] -> Generated Ticket: ${ticketIdStr}`);
                }
            });

            // Update Event's last_ticket_seq
            event.set("last_ticket_seq", eventLastSeq);
            txApp.save(event);
        });

        console.log(`[Hook] ✅ Successfully generated tickets for Booking ${bookingId}`);

    } catch (err) {
        console.error(`[Hook] ❌ Ticket Generation Failed: ${err.message}`);
    }

});
