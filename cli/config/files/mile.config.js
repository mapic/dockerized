module.exports = {
  "port": 3003,
  "redis": {
    "layers": {
      "port": 6379,
      "host": "redislayers",
      "auth": "e50cc8c747526de7c05f6c0ebb46cd0d015aad6f11b9ae7efe1784b19314d3319c756445154ebf08e97884cf09fc69a2f0a6a16957dbdcdb48da00587e97a21c",
      "db": 2
    },
    "stats": {
      "port": 6379,
      "host": "redisstats",
      "auth": "e50cc8c747526de7c05f6c0ebb46cd0d015aad6f11b9ae7efe1784b19314d3319c756445154ebf08e97884cf09fc69a2f0a6a16957dbdcdb48da00587e97a21c",
      "db": 2
    },
    "temp": {
      "port": 6379,
      "host": "redistemp",
      "auth": "e50cc8c747526de7c05f6c0ebb46cd0d015aad6f11b9ae7efe1784b19314d3319c756445154ebf08e97884cf09fc69a2f0a6a16957dbdcdb48da00587e97a21c",
      "db": 2
    }
  },
  "mongo": {
    "url": "mongodb://mongo/mapic"
  },
  "path": {
    "log": "/data/logs/"
  },
  "noAccessMessage": "No access. Please contact hello@mapic.io if you believe you are getting this message in error.",
  "noAccessTile": "public/noAccessTile.png",
  "processingTile": "public/noAccessTile.png",
  "defaultStylesheets": {
    "raster": "public/cartoid.xml",
    "utfgrid": "public/utfgrid.xml"
  }
}