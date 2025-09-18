/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2829451805")

  // remove field
  collection.fields.removeById("text848901969")

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "number1872009285",
    "max": null,
    "min": null,
    "name": "time",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2829451805")

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text848901969",
    "max": 0,
    "min": 0,
    "name": "score",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // remove field
  collection.fields.removeById("number1872009285")

  return app.save(collection)
})
