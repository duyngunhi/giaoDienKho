/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_666515910")

  // update collection data
  unmarshal({
    "name": "Card"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_666515910")

  // update collection data
  unmarshal({
    "name": "CardGame"
  }, collection)

  return app.save(collection)
})
