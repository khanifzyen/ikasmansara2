/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1866026747")

  // update collection data
  unmarshal({
    "createRule": "id != \"\"",
    "deleteRule": "author_id = @request.auth.id",
    "updateRule": "author_id = @request.auth.id"
  }, collection)

  // update field
  collection.fields.addAt(9, new Field({
    "cascadeDelete": false,
    "collectionId": "_pb_users_auth_",
    "hidden": false,
    "id": "relation75958508",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "author_id",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1866026747")

  // update collection data
  unmarshal({
    "createRule": null,
    "deleteRule": null,
    "updateRule": null
  }, collection)

  // update field
  collection.fields.addAt(9, new Field({
    "cascadeDelete": false,
    "collectionId": "_pb_users_auth_",
    "hidden": false,
    "id": "relation75958508",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "autho_id",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
})
