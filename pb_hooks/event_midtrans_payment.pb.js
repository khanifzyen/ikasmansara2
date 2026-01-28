/// <reference path="../pb_data/types.d.ts" />

/**
 * Midtrans Payment Hook (PocketBase v0.36+)
 */

onRecordCreateRequest((e) => {
    console.log("[Hook] onRecordCreateRequest triggered for event_bookings");

    try {
        // Load .env file inline
        let serverKey = "";
        try {
            const envPath = __hooks + "/.env";
            const content = $os.readFile(envPath);
            const lines = toString(content).split("\n");

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();
                if (line.startsWith("MIDTRANS_SERVER_KEY=")) {
                    serverKey = line.substring("MIDTRANS_SERVER_KEY=".length).trim();
                    if ((serverKey.startsWith('"') && serverKey.endsWith('"')) ||
                        (serverKey.startsWith("'") && serverKey.endsWith("'"))) {
                        serverKey = serverKey.slice(1, -1);
                    }
                    break;
                }
            }
            console.log("[Hook] ✅ .env loaded, key: " + (serverKey ? serverKey.substring(0, 10) + "..." : "EMPTY"));
        } catch (envErr) {
            console.error("[Hook] ⚠️ .env load failed:", envErr.message);
            serverKey = $os.getenv("MIDTRANS_SERVER_KEY") || "";
        }

        const eventId = e.record.getString("event");
        if (!eventId) throw new BadRequestError("Event ID is required");

        // Generate Booking ID
        const event = $app.findRecordById("events", eventId);
        const currentSeq = event.getInt("last_booking_seq") || 0;
        const nextSeq = currentSeq + 1;

        const format = event.getString("booking_id_format") || "{CODE}-{YEAR}-{SEQ}";
        const eventCode = event.getString("code") || "EVT";
        const year = new Date().getFullYear();
        const seqStr = nextSeq.toString().padStart(4, "0");

        const newBookingId = format
            .replace("{CODE}", eventCode)
            .replace("{YEAR}", year)
            .replace("{SEQ}", seqStr);

        console.log("[Hook] Generated Booking ID: " + newBookingId);

        event.set("last_booking_seq", nextSeq);
        $app.save(event);
        e.record.set("booking_id", newBookingId);

        // Request Midtrans Snap Token
        if (e.record.getString("payment_status") === "pending" && e.record.getInt("total_price") > 0) {
            if (!serverKey) {
                console.warn("[Hook] ⚠️ MIDTRANS_SERVER_KEY missing!");
            } else {
                const totalPrice = e.record.getInt("total_price");
                const userId = e.record.getString("user");

                let user;
                try {
                    user = $app.findRecordById("users", userId);
                } catch (uErr) {
                    console.warn("[Hook] User not found");
                }

                const isSandbox = serverKey.startsWith("SB-");
                const midtransUrl = isSandbox
                    ? "https://app.sandbox.midtrans.com/snap/v1/transactions"
                    : "https://app.midtrans.com/snap/v1/transactions";

                // Use Buffer for base64 encoding (PocketBase JSVM compatible)
                const authString = Buffer.from(serverKey + ":").toString("base64");

                const payload = {
                    transaction_details: {
                        order_id: newBookingId,
                        gross_amount: totalPrice
                    },
                    credit_card: { secure: true },
                    customer_details: user ? {
                        first_name: user.getString("name"),
                        email: user.getString("email"),
                        phone: user.getString("phone")
                    } : undefined,
                    enabled_payments: ["gopay", "shopeepay", "permata_va", "bca_va", "bni_va", "bri_va", "echannel", "other_va", "indomaret", "alfamart"]
                };

                const res = $http.send({
                    url: midtransUrl,
                    method: "POST",
                    body: JSON.stringify(payload),
                    headers: {
                        "Accept": "application/json",
                        "Content-Type": "application/json",
                        "Authorization": "Basic " + authString
                    },
                    timeout: 15
                });

                if (res.statusCode === 201 || res.statusCode === 200) {
                    const data = res.json;
                    console.log("[Hook] ✅ Midtrans Success. Token: " + data.token);
                    e.record.set("snap_token", data.token);
                    e.record.set("snap_redirect_url", data.redirect_url);
                } else {
                    console.error("[Hook] ❌ Midtrans Failed: " + res.statusCode);
                }
            }
        }

        e.next();

    } catch (err) {
        console.error("[Hook] ❌ ERROR: " + err.message);
        throw new BadRequestError("Booking creation failed: " + err.message);
    }

}, "event_bookings");
