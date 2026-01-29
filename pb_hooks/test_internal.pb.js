/// <reference path="../pb_data/types.d.ts" />

onAfterBootstrap((e) => {
    console.log("[Test Internal] Loaded. Run with: ./pocketbase test_post");
});

// Register a custom console command
$app.rootCmd.addCommand(new Command({
    use: "test_post",
    run: (cmd, args) => {
        const url = "http://127.0.0.1:8090/api/hello";

        console.log(`[Test Internal] Sending POST to ${url}...`);

        try {
            const res = $http.send({
                url: url,
                method: "POST",
                body: JSON.stringify({ test: "data from internal" }),
                headers: { "Content-Type": "application/json" },
                timeout: 5
            });

            console.log(`[Test Internal] Status: ${res.statusCode}`);
            console.log(`[Test Internal] Response: ${res.raw}`);
        } catch (err) {
            console.error(`[Test Internal] Error: ${err.message}`);
        }
    }
}));
