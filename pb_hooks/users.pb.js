/// <reference path="../pb_data/types.d.ts" />

/**
 * User Registration Hook for PocketBase v0.36+
 * Automatically assigns:
 * - no_urut_angkatan: Sequence number based on graduation year
 * - no_urut_global: Global sequence number across all users
 */

onRecordCreate((e) => {
    // Debug Log
    console.log("[Hook] onRecordCreate triggered for users collection");
    console.log("[Hook] Record data:", JSON.stringify(e.record.publicExport()));

    try {
        // --- 1. Global Sequence (Year = 0) ---
        let globalSeqRecord;
        try {
            // Try to find existing global sequence record
            globalSeqRecord = $app.findFirstRecordByData("registration_sequences", "year", 0);
        } catch (err) {
            console.log("[Hook] Global sequence not found, creating new one.");
            // If not found, create it
            const seqCollection = $app.findCollectionByNameOrId("registration_sequences");
            globalSeqRecord = new Record(seqCollection);
            globalSeqRecord.set("year", 0);
            globalSeqRecord.set("last_number", 0);
            $app.save(globalSeqRecord);
        }

        // Increment global counter
        const newGlobalSeq = globalSeqRecord.getInt("last_number") + 1;
        console.log("[Hook] New Global Seq:", newGlobalSeq);

        globalSeqRecord.set("last_number", newGlobalSeq);
        $app.save(globalSeqRecord);

        // Assign to user record
        e.record.set("no_urut_global", newGlobalSeq);

        // --- 2. Angkatan Sequence ---
        const angkatan = e.record.getInt("angkatan");
        console.log("[Hook] Angkatan input:", angkatan);

        // Only process if angkatan is provided (not 0 or null)
        if (angkatan > 0) {
            let angkatanSeqRecord;
            try {
                // Try to find existing angkatan sequence record
                angkatanSeqRecord = $app.findFirstRecordByData("registration_sequences", "year", angkatan);
            } catch (err) {
                console.log("[Hook] Angkatan sequence not found for year " + angkatan + ", creating new one.");
                // If not found, create it
                const seqCollection = $app.findCollectionByNameOrId("registration_sequences");
                angkatanSeqRecord = new Record(seqCollection);
                angkatanSeqRecord.set("year", angkatan);
                angkatanSeqRecord.set("last_number", 0);
                $app.save(angkatanSeqRecord);
            }

            // Increment angkatan counter
            const newAngkatanSeq = angkatanSeqRecord.getInt("last_number") + 1;
            console.log("[Hook] New Angkatan Seq:", newAngkatanSeq);

            angkatanSeqRecord.set("last_number", newAngkatanSeq);
            $app.save(angkatanSeqRecord);

            // Assign to user record
            e.record.set("no_urut_angkatan", newAngkatanSeq);
        } else {
            console.log("[Hook] No valid angkatan provided, skipping angkatan sequence.");
        }

        // Continue with the record creation
        e.next();

    } catch (err) {
        console.log("[Hook] ERROR:", err.message);
        // Throw error to block creation for data integrity
        throw new BadRequestError("Failed to generate registration sequences: " + err.message);
    }
}, "users");
