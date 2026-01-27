/// <reference path="../pb_data/types.d.ts" />

/**
 * Midtrans Payment Hook (PocketBase v0.36+)
 * 
 * Logic in onRecordCreate (runs before persistence):
 * 1. AUTO-GENERATE Booking ID ({CODE}-{YEAR}-{SEQ})
 * 2. REQUEST Snap Token from Midtrans
 * 3. UPDATE Record with Token & Booking ID
 */

onRecordCreate((e) => {
    // ---------------------------------------------------------------------
    // Configuration & Helpers
    // ---------------------------------------------------------------------
    const COLLECTION = "event_bookings";

    // Only run for event_bookings
    if (e.record.collection().name !== COLLECTION) return;

    console.log(`[Hook] onRecordCreate triggered for ${COLLECTION}`);
    console.log("[Hook] Record data preview:", JSON.stringify(e.record.publicExport()));

    try {
        const eventId = e.record.getString("event");
        if (!eventId) throw new BadRequestError("Event ID is required");

        // -----------------------------------------------------------------
        // 1. Generate Booking ID
        // -----------------------------------------------------------------
        console.log(`[Hook] strict: Generating Booking ID for Event ${eventId}...`);

        const event = $app.findRecordById("events", eventId);

        // Concurrency Lock usually needed? JSVM is single-threaded per request, but let's assume simple increment is safe enough for low volume.
        // Get current sequence
        const currentSeq = event.getInt("last_booking_seq") || 0;
        const nextSeq = currentSeq + 1;

        const format = event.getString("booking_id_format") || "{CODE}-{YEAR}-{SEQ}";
        const eventCode = event.getString("code") || "EVT";
        const year = new Date().getFullYear();
        const seqStr = nextSeq.toString().padStart(4, "0"); // 0001

        const newBookingId = format
            .replace("{CODE}", eventCode)
            .replace("{YEAR}", year)
            .replace("{SEQ}", seqStr);

        console.log(`[Hook] Generated Booking ID: ${newBookingId}`);

        // Update Event Sequence immediately
        // Note: If transaction fails later, we have a gap in sequence. Generally acceptable.
        event.set("last_booking_seq", nextSeq);
        $app.save(event);

        // Set ID to current record
        e.record.set("booking_id", newBookingId);

        // -----------------------------------------------------------------
        // 2. Request Midtrans Snap Token
        // -----------------------------------------------------------------
        // Only if status is pending and we have a price
        if (e.record.getString("payment_status") === "pending" && e.record.getInt("total_price") > 0) {
            console.log("[Hook] Requesting Midtrans Snap Token...");

            const serverKey = $os.getenv("MIDTRANS_SERVER_KEY");
            if (!serverKey) {
                console.warn("[Hook] ⚠️ MIDTRANS_SERVER_KEY is missing! Skipping Snap generation.");
            } else {
                const totalPrice = e.record.getInt("total_price");
                const userId = e.record.getString("user");

                // Fetch user details for Midtrans
                let user;
                try {
                    user = $app.findRecordById("users", userId);
                } catch (uErr) {
                    console.warn("[Hook] User not found, sending minimal data.");
                }

                // Determine Environment
                const isSandbox = serverKey.startsWith("SB-");
                const midtransUrl = isSandbox
                    ? "https://app.sandbox.midtrans.com/snap/v1/transactions"
                    : "https://app.midtrans.com/snap/v1/transactions";

                console.log(`[Hook] Env: ${isSandbox ? "Sandbox" : "Production"}`);

                // Basic Auth Header
                const authString = toBase64(serverKey + ":");

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
                    enabled_payments: [
                        "gopay", "shopeepay", "permata_va", "bca_va", "bni_va", "bri_va", "echannel", "other_va", "indomaret", "alfamart"
                    ]
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
                    console.log("[Hook] ✅ Midtrans Snap Success. Token:", data.token);

                    // Set fields to record (will be saved when e.next() is called)
                    e.record.set("snap_token", data.token);
                    e.record.set("snap_redirect_url", data.redirect_url);
                } else {
                    console.error(`[Hook] ❌ Midtrans Failed: ${res.statusCode} - ${res.raw}`);
                    // Optional: Throw error to prevent booking creation if payment init fails?
                    // throw new BadRequestError("Payment gateway initialization failed.");
                }
            }
        }

        // Proceed data persistence
        e.next();

    } catch (err) {
        console.error("[Hook] ❌ ERROR:", err.message);
        throw new BadRequestError("Booking creation failed: " + err.message);
    }

}, "event_bookings");


// -------------------------------------------------------------------------
// Helper: Base64 Encoder
// -------------------------------------------------------------------------
function toBase64(input) {
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    var str = String(input);
    var output = '';

    for (var block = 0, charCode, i = 0, map = chars;
        str.charAt(i | 0) || (map = '=', i % 1);
        output += map.charAt(63 & block >> 8 - i % 1 * 8)) {

        charCode = str.charCodeAt(i += 3 / 4);

        if (charCode > 0xFF) {
            throw new Error("'btoa' failed: The string to be encoded contains characters outside of the Latin1 range.");
        }

        block = block << 8 | charCode;
    }

    return output;
}
