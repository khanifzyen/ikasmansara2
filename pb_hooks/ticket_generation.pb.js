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
        // Get Manual Booking Info
        // -----------------------------------------------------------------
        const manualCount = e.record.getInt("manual_ticket_count");
        const manualTicketTypeId = e.record.getString("manual_ticket_type");
        const coordinatorName = e.record.getString("coordinator_name");

        // -----------------------------------------------------------------
        // Parse Metadata
        // -----------------------------------------------------------------
        console.log("[Hook] 📦 Parsing metadata...");
        let metadata = e.record.get("metadata");
        let items = [];

        try {
            if (metadata) {
                // Case 1: Metadata is already a JS object/array
                if (Array.isArray(metadata)) {
                    if (metadata.length > 0 && typeof metadata[0] === 'number') {
                        console.log("[Hook] 🔢 Detected Byte Array metadata. Converting to string...");
                        const jsonString = metadata.map(b => String.fromCharCode(b)).join('');
                        console.log(`[Hook] 📝 Raw JSON: ${jsonString}`);
                        if (jsonString && jsonString !== 'null') {
                            const parsed = JSON.parse(jsonString);
                            items = Array.isArray(parsed) ? parsed : (parsed ? [parsed] : []);
                        }
                    } else {
                        items = metadata;
                    }
                }
                // Case 2: Metadata is a string
                else if (typeof metadata === 'string' && metadata !== 'null') {
                    const parsed = JSON.parse(metadata);
                    items = Array.isArray(parsed) ? parsed : (parsed ? [parsed] : []);
                }
                // Case 3: Metadata is an object
                else if (typeof metadata === 'object') {
                    const raw = JSON.stringify(metadata);
                    if (raw !== 'null') {
                        const parsed = JSON.parse(raw);
                        items = Array.isArray(parsed) ? parsed : (parsed ? [parsed] : []);
                    }
                }
            }
        } catch (err) {
            console.warn(`[Hook] ⚠️ Metadata parse error: ${err.message}`);
        }

        // Ensure items is always an array
        if (!Array.isArray(items)) {
            items = [];
        }

        // Final validation: skip if no metadata AND no manual booking info
        if (items.length === 0 && (manualCount <= 0 || !manualTicketTypeId)) {
            console.warn(`[Hook] ⚠️ No valid items found in metadata and not a valid manual booking for ${bookingId}.`);
            return;
        }

        console.log(`[Hook] 🛒 Items Found: ${items.length}, Manual Count: ${manualCount}`);

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
        // Generate Tickets
        // -----------------------------------------------------------------
        console.log("[Hook] 🔄 Starting Ticket Generation (No Transaction)...");
        const bookingsTicketsCollection = $app.findCollectionByNameOrId("event_booking_tickets");

        if (manualCount > 0 && manualTicketTypeId) {
            console.log(`[Hook] ⚡ Manual Booking Detected. Count: ${manualCount}, Type: ${manualTicketTypeId}`);

            // Update 'sold' count for manual type
            try {
                const ticketTypeRecord = $app.findRecordById("event_tickets", manualTicketTypeId);
                const currentSold = ticketTypeRecord.getInt("sold");
                ticketTypeRecord.set("sold", currentSold + manualCount);
                $app.save(ticketTypeRecord);
            } catch (err) {
                console.error(`[Hook] ❌ Failed to update sold count for ticket ${manualTicketTypeId}: ${err.message}`);
                throw err;
            }

            // Batch create tickets
            for (let i = 0; i < manualCount; i++) {
                eventLastSeq++;
                const seqStr = eventLastSeq.toString().padStart(4, "0");
                const ticketIdStr = ticketFormat
                    .replace("{CODE}", eventCode)
                    .replace("{SEQ}", seqStr);

                const newTicket = new Record(bookingsTicketsCollection);
                newTicket.set("ticket_id", ticketIdStr);
                newTicket.set("booking", bookingId);
                newTicket.set("ticket_type", manualTicketTypeId);
                newTicket.set("user_name", coordinatorName);
                newTicket.set("shirt_picked_up", false);
                newTicket.set("checked_in", false);

                $app.save(newTicket);
                console.log(`[Hook] -> Generated Manual Ticket: ${ticketIdStr}`);
            }

        } else {
            // Standard Metadata Flow
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
        }

        // Update Event's last_ticket_seq
        event.set("last_ticket_seq", eventLastSeq);
        $app.save(event);
        console.log("[Hook] 💾 Event sequence updated.");


        console.log(`[Hook] ✅ Successfully generated tickets for Booking ${bookingId}`);

    } catch (err) {
        console.error(`[Hook] ❌ Ticket Generation Failed: ${err.message}`);
    }

}, "event_bookings");
