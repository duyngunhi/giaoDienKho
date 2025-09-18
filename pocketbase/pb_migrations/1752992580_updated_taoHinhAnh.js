/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3918225676")

  // update collection data
  unmarshal({
    "name": "taoAnh"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3918225676")

  // update collection data
  unmarshal({
    "name": "taoHinhAnh"
  }, collection)

  return app.save(collection)
})
