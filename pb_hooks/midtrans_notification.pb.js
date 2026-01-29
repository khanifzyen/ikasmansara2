/// <reference path="../pb_data/types.d.ts" />

routerAdd("POST", "/api/midtrans/notification", (e) => {
    let data;
    try {
        data = e.requestInfo().body;
        console.log("[Midtrans Webhook] Received:", JSON.stringify(data));
    } catch (parseErr) {
        console.error("[Midtrans Webhook] Failed to parse JSON:", parseErr);
        return e.json(400, { message: "Invalid JSON body" });
    }

    const orderId = data.order_id;
    const transactionStatus = data.transaction_status;
    const fraudStatus = data.fraud_status;

    if (!orderId) {
        console.warn("[Midtrans Webhook] Missing order_id in payload:", JSON.stringify(data));
        return e.json(400, { message: "Invalid payload: missing order_id" });
    }

    // --- Audit Trail: Save to midtrans_logs ---
    try {
        const logCollection = $app.findCollectionByNameOrId("midtrans_logs");
        const logRecord = new Record(logCollection);

        logRecord.set("order_id", orderId);
        logRecord.set("transaction_id", data.transaction_id);
        logRecord.set("transaction_status", transactionStatus);
        logRecord.set("payment_type", data.payment_type);
        // Ensure gross_amount is treated as number/string appropriately
        logRecord.set("gross_amount", data.gross_amount);
        logRecord.set("fraud_status", fraudStatus);
        logRecord.set("status_code", data.status_code);
        logRecord.set("raw_body", data);

        $app.save(logRecord);
        console.log(`[Midtrans Webhook] Audit log saved for ${orderId}`);
    } catch (auditErr) {
        console.error(`[Midtrans Webhook] Failed to save audit log: ${auditErr.message}`);
        // We continue execution because updating the booking status is the priority
    }
    // -------------------------------------------

    try {
        // 2. Find Booking Record
        // order_id is stored in 'booking_id' field, but we need to find the record by that field.
        const result = $app.findRecordsByFilter(
            "event_bookings",
            `booking_id = '${orderId}'`,
            "-created",
            1,
            0
        );

        if (!result || result.length === 0) {
            console.warn(`[Midtrans Webhook] Booking not found: ${orderId}`);
            return e.json(404, { message: "Booking not found" });
        }

        const booking = result[0];
        const currentStatus = booking.getString("payment_status");

        if (currentStatus === "paid" || currentStatus === "refunded" || currentStatus === "expired") {
            console.log(`[Midtrans Webhook] Booking ${orderId} already ${currentStatus}. Ignoring.`);
            return e.json(200, { message: "OK" });
        }

        // 3. Determine New Status
        let newStatus = currentStatus;

        if (transactionStatus == "capture") {
            if (fraudStatus == "challenge") {
                // DO NOT update to paid yet, wait for approve
                newStatus = "pending";
            } else if (fraudStatus == "accept") {
                newStatus = "paid";
            }
        } else if (transactionStatus == "settlement") {
            newStatus = "paid";
        } else if (transactionStatus == "cancel" ||
            transactionStatus == "deny" ||
            transactionStatus == "expire") {
            newStatus = "failed"; // or 'expired'
        } else if (transactionStatus == "pending") {
            newStatus = "pending";
        }

        // 4. Update Record if status changed
        if (newStatus !== currentStatus && newStatus === "paid") {
            console.log(`[Midtrans Webhook] Updating ${orderId} status to PAID`);
            booking.set("payment_status", "paid");

            // Optionally set payment_method and payment_date
            if (data.payment_type) {
                booking.set("payment_method", data.payment_type);
            }
            booking.set("payment_date", new Date());

            // Ticket generation and sold count update is handled by
            // pb_hooks/ticket_generation.pb.js (triggered by payment_status='paid')

            $app.save(booking);
        } else if (newStatus !== currentStatus && newStatus === "failed") {
            console.log(`[Midtrans Webhook] Updating ${orderId} status to FAILED/EXPIRED`);
            booking.set("payment_status", "expired");
            $app.save(booking);
        }

        return e.json(200, { message: "OK" });

    } catch (err) {
        console.error(`[Midtrans Webhook] Error: ${err.message}`);
        return e.json(500, { message: err.message });
    }
});
