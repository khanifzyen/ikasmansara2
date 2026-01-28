/// <reference path="../pb_data/types.d.ts" />

routerAdd("POST", "/midtrans/notification", (c) => {
    // 1. Parse Notification JSON
    const data = c.request().json();
    console.log("[Midtrans Webhook] Received:", JSON.stringify(data));

    const orderId = data.order_id;
    const transactionStatus = data.transaction_status;
    const fraudStatus = data.fraud_status;

    if (!orderId) {
        return c.json(400, { message: "Invalid order_id" });
    }

    // --- Audit Trail: Save to midtrans_logs ---
    try {
        const logCollection = $app.dao().findCollectionByNameOrId("midtrans_logs");
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

        $app.dao().saveRecord(logRecord);
        console.log(`[Midtrans Webhook] Audit log saved for ${orderId}`);
    } catch (auditErr) {
        console.error(`[Midtrans Webhook] Failed to save audit log: ${auditErr.message}`);
        // We continue execution because updating the booking status is the priority
    }
    // -------------------------------------------

    try {
        // 2. Find Booking Record
        // order_id is stored in 'booking_id' field, but we need to find the record by that field.
        const result = $app.dao().findRecordsByFilter(
            "event_bookings",
            `booking_id = '${orderId}'`,
            "-created",
            1
        );

        if (!result || result.length === 0) {
            console.warn(`[Midtrans Webhook] Booking not found: ${orderId}`);
            return c.json(404, { message: "Booking not found" });
        }

        const booking = result[0];
        const currentStatus = booking.getString("payment_status");

        if (currentStatus === "paid" || currentStatus === "refunded" || currentStatus === "expired") {
            console.log(`[Midtrans Webhook] Booking ${orderId} already ${currentStatus}. Ignoring.`);
            return c.json(200, { message: "OK" });
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
            console.log(`[Midtrans Webhook] Updating ${orderId} status to PAId`);
            booking.set("payment_status", "paid");

            // Optionally set payment_method and payment_date
            if (data.payment_type) {
                booking.set("payment_method", data.payment_type);
            }
            booking.set("payment_date", new Date());

            $app.dao().saveRecord(booking);
        } else if (newStatus !== currentStatus && newStatus === "failed") {
            console.log(`[Midtrans Webhook] Updating ${orderId} status to FAILED/EXPIRED`);
            booking.set("payment_status", "expired");
            $app.dao().saveRecord(booking);
        }

        return c.json(200, { message: "OK" });

    } catch (err) {
        console.error(`[Midtrans Webhook] Error: ${err.message}`);
        return c.json(500, { message: err.message });
    }
});
