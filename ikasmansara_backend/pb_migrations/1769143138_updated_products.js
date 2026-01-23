/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("col_products_00")

  // remove field
  collection.fields.removeById("text1843675174")

  // remove field
  collection.fields.removeById("select1343667783")

  // add field
  collection.fields.addAt(2, new Field({
    "convertURLs": false,
    "hidden": false,
    "id": "editor1843675174",
    "maxSize": 0,
    "name": "description",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "editor"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text105650625",
    "max": 0,
    "min": 0,
    "name": "category",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("col_products_00")

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1843675174",
    "max": 0,
    "min": 0,
    "name": "description",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "select1343667783",
    "maxSelect": 1,
    "name": "categoty",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "Kuliner",
      "Jasa",
      "Fashion",
      "Properti",
      "Lainnya"
    ]
  }))

  // remove field
  collection.fields.removeById("editor1843675174")

  // remove field
  collection.fields.removeById("text105650625")

  return app.save(collection)
})
