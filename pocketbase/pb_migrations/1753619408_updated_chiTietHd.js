/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3568174403")

  // update field
  collection.fields.addAt(1, new Field({
    "hidden": false,
    "id": "bool1691978669",
    "name": "loaiHd",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3568174403")

  // update field
  collection.fields.addAt(1, new Field({
    "hidden": false,
    "id": "bool1691978669",
    "name": "LoaiHd",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
})
