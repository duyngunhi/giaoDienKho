/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4130975176")

  // update field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "file3355779831",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/png",
      "video/webm",
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
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_4130975176")

  // update field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "file3355779831",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/png",
      "video/webm",
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
})
