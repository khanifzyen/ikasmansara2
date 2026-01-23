/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("col_products_00")

  // update collection data
  unmarshal({
    "createRule": "id != \"\"",
    "deleteRule": "seller_id = @request.auth.id",
    "updateRule": "seller_id = @request.auth.id"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("col_products_00")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.id != ''",
    "deleteRule": null,
    "updateRule": null
  }, collection)

  return app.save(collection)
})
