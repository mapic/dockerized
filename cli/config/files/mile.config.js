module.exports = {
  "port": 3003,
  "redis": {
    "layers": {
      "port": 6379,
      "host": "redislayers",
      "auth": "fa77e0bdcffbecd6680081cfebaeb14ce9658918d8446d7df6c2f5f480d6a0a407a13f711b243756af99f5c6e8dad736883a53aadb7a6b012b67c4760ae0c823",
      "db": 2
    },
    "stats": {
      "port": 6379,
      "host": "redisstats",
      "auth": "fa77e0bdcffbecd6680081cfebaeb14ce9658918d8446d7df6c2f5f480d6a0a407a13f711b243756af99f5c6e8dad736883a53aadb7a6b012b67c4760ae0c823",
      "db": 2
    },
    "temp": {
      "port": 6379,
      "host": "redistemp",
      "auth": "fa77e0bdcffbecd6680081cfebaeb14ce9658918d8446d7df6c2f5f480d6a0a407a13f711b243756af99f5c6e8dad736883a53aadb7a6b012b67c4760ae0c823",
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