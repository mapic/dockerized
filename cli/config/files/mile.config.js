module.exports = {
  "port": 3003,
  "redis": {
    "layers": {
      "port": 6379,
      "host": "redislayers",
      "auth": "8bb095194c183af99715d7615cdc571ac5cd91839aab8c70a3178e58b6030c2bc1c1fadbf4018ae9c00f4aa232093e4863e2b7d366381e72907012f0ac2aeef4",
      "db": 2
    },
    "stats": {
      "port": 6379,
      "host": "redisstats",
      "auth": "8bb095194c183af99715d7615cdc571ac5cd91839aab8c70a3178e58b6030c2bc1c1fadbf4018ae9c00f4aa232093e4863e2b7d366381e72907012f0ac2aeef4",
      "db": 2
    },
    "temp": {
      "port": 6379,
      "host": "redistemp",
      "auth": "8bb095194c183af99715d7615cdc571ac5cd91839aab8c70a3178e58b6030c2bc1c1fadbf4018ae9c00f4aa232093e4863e2b7d366381e72907012f0ac2aeef4",
      "db": 2
    }
  },
  "mongo": {
    "url": "mongodb://mongo/mapic"
  },
  "path": {
    "log": "/data/logs/"
  },
  "noAccessMessage": "No access. Please contact Systemapic.com if you believe you are getting this message in error.",
  "noAccessTile": "public/noAccessTile.png",
  "processingTile": "public/noAccessTile.png",
  "defaultStylesheets": {
    "raster": "public/cartoid.xml",
    "utfgrid": "public/utfgrid.xml"
  }
}