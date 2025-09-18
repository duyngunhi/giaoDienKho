/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2829451805")

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "number2289690853",
    "max": null,
    "min": null,
    "name": "rank",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2829451805")

  // remove field
  collection.fields.removeById("number2289690853")

  return app.save(collection)
})
