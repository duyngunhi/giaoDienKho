/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3568174403")

  // remove field
  collection.fields.removeById("number3546427801")

  // add field
  collection.fields.addAt(9, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text3546427801",
    "max": 0,
    "min": 0,
    "name": "maHd",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3568174403")

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "number3546427801",
    "max": null,
    "min": null,
    "name": "maHd",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  // remove field
  collection.fields.removeById("text3546427801")

  return app.save(collection)
})
