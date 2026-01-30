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

onRecordAfterUpdateSuccess((e) => {
    console.log(`[Hook] 🔍 event_bookings update detected: ${e.record.id}`);

    // We only care if the NEW state is 'paid'
    if (e.record.getString("payment_status") !== "paid") {
        return;
    }

    console.log(`[Hook] 🎫 processing ticket generation for Booking ${e.record.id}...`);

    try {
        const bookingId = e.record.id;
        const eventId = e.record.getString("event");
        console.log(`[Hook] 🆔 Booking: ${bookingId}, Event: ${eventId}`);

        // -----------------------------------------------------------------
        // Idempotency Check
        // -----------------------------------------------------------------
        console.log("[Hook] 🔍 Checking existing tickets...");
        // Use $app.findRecordsByFilter (helper) instead of $app.dao()...
        // Signature: (collection, filter, sort, limit, offset)
        const existingTickets = $app.findRecordsByFilter(
            "event_booking_tickets",
            `booking = '${bookingId}'`,
            "-created",
            1,
            0
        );

        if (existingTickets.length > 0) {
            console.log(`[Hook] ⚠️ Tickets already exist for booking ${bookingId}. Skipping generation.`);
            return;
        }

        // -----------------------------------------------------------------
        // Parse Metadata
        // -----------------------------------------------------------------
        console.log("[Hook] 📦 Parsing metadata...");
        let metadata = e.record.get("metadata");
        let items = [];

        try {
            // Case 1: Metadata is already a JS object/array (rare but possible)
            if (Array.isArray(metadata)) {
                // Check if it's a byte array (PocketBase sometimes returns []uint8 as array of numbers)
                if (metadata.length > 0 && typeof metadata[0] === 'number') {
                    console.log("[Hook] 🔢 Detected Byte Array metadata. Converting to string...");
                    // Convert byte array to string
                    const jsonString = metadata.map(b => String.fromCharCode(b)).join('');
                    items = JSON.parse(jsonString);
                } else {
                    // It's a regular array of objects
                    items = metadata;
                }
            }
            // Case 2: Metadata is a string
            else if (typeof metadata === 'string') {
                items = JSON.parse(metadata);
            }
            // Case 3: Metadata is an object (single item or weird wrapper)
            else if (metadata && typeof metadata === 'object') {
                // Try to stringify and parse again if it's some internal Go wrapper
                const raw = JSON.stringify(metadata);
                // If raw looks like a byte array string "[91, 123...]", we might need to handle it,
                // but typically JSON.stringify on object handles it.
                // However, if it was an object like {0: 91, 1: 123...}, that's different.
                // Let's assume standard object behavior first.
                try {
                    const parsed = JSON.parse(raw);
                    if (Array.isArray(parsed)) items = parsed;
                    else items = [parsed];
                } catch (_) {
                    // Fallback: assume it's a single item object
                    items = [metadata];
                }
            }
        } catch (err) {
            console.warn(`[Hook] ⚠️ Metadata parse error: ${err.message}`);
        }

        // Final validation
        if (!Array.isArray(items)) {
            items = [];
        }

        // Debug log
        try {
            console.log(`[Hook] 🛒 Parsed ${items.length} items. First item type: ${items.length > 0 ? typeof items[0] : 'N/A'}`);
        } catch (_) { }

        if (items.length === 0) {
            console.warn(`[Hook] ⚠️ No valid items found in metadata for booking ${bookingId}.`);
            return;
        }

        // -----------------------------------------------------------------
        // Prepare Event & Sequences
        // -----------------------------------------------------------------
        console.log("[Hook] 📅 Fetching Event record...");
        // Use $app.findRecordById
        const event = $app.findRecordById("events", eventId);
        let eventLastSeq = event.getInt("last_ticket_seq") || 0;

        const ticketFormat = event.getString("ticket_id_format") || "TIX-{CODE}-{SEQ}";
        const eventCode = event.getString("code") || "EVT";
        console.log(`[Hook] 🔢 Current Last Seq: ${eventLastSeq}, Code: ${eventCode}`);

        // -----------------------------------------------------------------
        // Generate Tickets (Transaction)
        // -----------------------------------------------------------------
        // -----------------------------------------------------------------
        // Generate Tickets
        // -----------------------------------------------------------------
        console.log("[Hook] 🔄 Starting Ticket Generation (No Transaction)...");

        // Note: We removed runInTransaction to avoid potential deadlocks/hanging.
        // If an error occurs midway, we might have partial data.

        const bookingsTicketsCollection = $app.findCollectionByNameOrId("event_booking_tickets");

        items.forEach(item => {
            const ticketTypeId = item.ticket_type_id;
            const qty = parseInt(item.quantity);
            const options = item.options || {};

            console.log(`[Hook] 🎫 Processing Item: ${ticketTypeId}, Qty: ${qty}`);

            if (!ticketTypeId || isNaN(qty) || qty <= 0) return;

            // Update 'sold' count
            try {
                const ticketTypeRecord = $app.findRecordById("event_tickets", ticketTypeId);
                const currentSold = ticketTypeRecord.getInt("sold");
                ticketTypeRecord.set("sold", currentSold + qty);
                $app.save(ticketTypeRecord);
            } catch (err) {
                console.error(`[Hook] ❌ Failed to update sold count for ticket ${ticketTypeId}: ${err.message}`);
                throw err;
            }

            // Create tickets
            for (let i = 0; i < qty; i++) {
                eventLastSeq++;
                const seqStr = eventLastSeq.toString().padStart(4, "0");
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

                $app.save(newTicket);
                console.log(`[Hook] -> Generated Ticket: ${ticketIdStr}`);
            }
        });

        // Update Event's last_ticket_seq
        event.set("last_ticket_seq", eventLastSeq);
        $app.save(event);
        console.log("[Hook] 💾 Event sequence updated.");


        console.log(`[Hook] ✅ Successfully generated tickets for Booking ${bookingId}`);

    } catch (err) {
        console.error(`[Hook] ❌ Ticket Generation Failed: ${err.message}`);
    }

}, "event_bookings");
