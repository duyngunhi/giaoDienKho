/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3918225676")

  // update field
  collection.fields.addAt(1, new Field({
    "hidden": false,
    "id": "file454155546",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/png",
      "image/svg+xml",
      "image/webp",
      "image/gif"
    ],
    "name": "hinhAnhSp",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": [],
    "type": "file"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3918225676")

  // update field
  collection.fields.addAt(1, new Field({
    "hidden": false,
    "id": "file454155546",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/png",
      "image/svg+xml",
      "image/webp",
      "image/gif"
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
})
