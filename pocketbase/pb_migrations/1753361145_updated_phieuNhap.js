/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_390524097")

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "number1090101708",
    "max": null,
    "min": null,
    "name": "giaBanSp",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_390524097")

  // remove field
  collection.fields.removeById("number1090101708")

  return app.save(collection)
})
