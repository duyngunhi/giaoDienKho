/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1496276556")

  // update collection data
  unmarshal({
    "name": "phieuXuat"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1496276556")

  // update collection data
  unmarshal({
    "name": "phieuNhap_duplicate"
  }, collection)

  return app.save(collection)
})
