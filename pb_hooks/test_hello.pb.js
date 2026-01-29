/// <reference path="../pb_data/types.d.ts" />

routerAdd("GET", "/api/hello", (e) => {
    console.log(`[Test Hook] GET /api/hello called. Method: ${e.request.method}`);
    return e.json(200, { message: "Hello World from GET", method: e.request.method });
});

routerAdd("POST", "/api/hello", (e) => {
    console.log(`[Test Hook] POST /api/hello called. Method: ${e.request.method}`);
    try {
        const data = e.requestInfo().body;
        return e.json(200, {
            message: "Hello World from POST",
            received_data: data,
            method: e.request.method
        });
    } catch (err) {
        return e.json(200, { message: "Hello World from POST (No JSON body)", method: e.request.method });
    }
});
