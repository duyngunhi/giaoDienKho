/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2829451805")

  // update collection data
  unmarshal({
    "name": "player"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2829451805")

  // update collection data
  unmarshal({
    "name": "Player"
  }, collection)

  return app.save(collection)
})
