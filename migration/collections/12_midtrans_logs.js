/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
    const collection = new Collection({
        "id": "midtrans_logs_01",
        "created": "2024-01-28 00:00:00.000Z",
        "updated": "2024-01-28 00:00:00.000Z",
        "name": "midtrans_logs",
        "type": "base",
        "system": false,
        "schema": [
            {
                "system": false,
                "id": "order_id",
                "name": "order_id",
                "type": "text",
                "required": true,
                "presentable": false,
                "unique": false,
                "options": {
                    "min": null,
                    "max": null,
                    "pattern": ""
                }
            },
            {
                "system": false,
                "id": "transaction_id",
                "name": "transaction_id",
                "type": "text",
                "required": true,
                "presentable": false,
                "unique": false,
                "options": {
                    "min": null,
                    "max": null,
                    "pattern": ""
                }
            },
            {
                "system": false,
                "id": "transaction_status",
                "name": "transaction_status",
                "type": "text",
                "required": true,
                "presentable": false,
                "unique": false,
                "options": {
                    "min": null,
                    "max": null,
                    "pattern": ""
                }
            },
            {
                "system": false,
                "id": "payment_type",
                "name": "payment_type",
                "type": "text",
                "required": false,
                "presentable": false,
                "unique": false,
                "options": {
                    "min": null,
                    "max": null,
                    "pattern": ""
                }
            },
            {
                "system": false,
                "id": "gross_amount",
                "name": "gross_amount",
                "type": "text",
                "required": false,
                "presentable": false,
                "unique": false,
                "options": {
                    "min": null,
                    "max": null,
                    "pattern": ""
                }
            },
            {
                "system": false,
                "id": "fraud_status",
                "name": "fraud_status",
                "type": "text",
                "required": false,
                "presentable": false,
                "unique": false,
                "options": {
                    "min": null,
                    "max": null,
                    "pattern": ""
                }
            },
            {
                "system": false,
                "id": "status_code",
                "name": "status_code",
                "type": "text",
                "required": false,
                "presentable": false,
                "unique": false,
                "options": {
                    "min": null,
                    "max": null,
                    "pattern": ""
                }
            },
            {
                "system": false,
                "id": "raw_body",
                "name": "raw_body",
                "type": "json",
                "required": true,
                "presentable": false,
                "unique": false,
                "options": {
                    "maxSize": 2000000
                }
            }
        ],
        "indexes": [
            "CREATE INDEX `idx_order_id` ON `midtrans_logs` (`order_id`)"
        ],
        "listRule": "@request.auth.id != '' && @request.auth.isAdmin = true",
        "viewRule": "@request.auth.id != '' && @request.auth.isAdmin = true",
        "createRule": null,
        "updateRule": null,
        "deleteRule": null,
        "options": {}
    });

    return Dao(db).saveCollection(collection);
}, (db) => {
    const dao = new Dao(db);
    const collection = dao.findCollectionByNameOrId("midtrans_logs");

    return dao.deleteCollection(collection);
})
