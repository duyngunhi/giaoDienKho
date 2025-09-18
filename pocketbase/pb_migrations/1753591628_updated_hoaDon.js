/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3312598795")

  // remove field
  collection.fields.removeById("number3893104977")

  // add field
  collection.fields.addAt(5, new Field({
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
  const collection = app.findCollectionByNameOrId("pbc_3312598795")

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "number3893104977",
    "max": null,
    "min": null,
    "name": "maHD",
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
