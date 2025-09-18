/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_390524097")

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "file1542800728",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/gif",
      "image/webp",
      "image/png",
      "image/svg+xml"
    ],
    "name": "hinhAnh",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": [],
    "type": "file"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_390524097")

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "file1542800728",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/gif",
      "image/webp",
      "image/png",
      "image/svg+xml"
    ],
    "name": "field",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": [],
    "type": "file"
  }))

  return app.save(collection)
})
