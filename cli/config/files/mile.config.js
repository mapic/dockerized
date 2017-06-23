module.exports = {
  "port": 3003,
  "redis": {
    "layers": {
      "port": 6379,
      "host": "redislayers",
      "auth": "d01914d02eaf5968cd953f732fa224b7f8b646f3c22b32ef8689b041c44f96369fac40b27d0e97515f8d17d09b6a6f0cf12c90cdd52f0f59f67409a55d5c26d4",
      "db": 2
    },
    "stats": {
      "port": 6379,
      "host": "redisstats",
      "auth": "d01914d02eaf5968cd953f732fa224b7f8b646f3c22b32ef8689b041c44f96369fac40b27d0e97515f8d17d09b6a6f0cf12c90cdd52f0f59f67409a55d5c26d4",
      "db": 2
    },
    "temp": {
      "port": 6379,
      "host": "redistemp",
      "auth": "d01914d02eaf5968cd953f732fa224b7f8b646f3c22b32ef8689b041c44f96369fac40b27d0e97515f8d17d09b6a6f0cf12c90cdd52f0f59f67409a55d5c26d4",
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