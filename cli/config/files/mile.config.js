module.exports = {
  "port": 3003,
  "redis": {
    "layers": {
      "port": 6379,
      "host": "redislayers",
      "auth": "57665cc148dc9e9887c7046d9ccaaa9cb4f5b759d9182036d8c81a709d2ef029a3b4dcf431d4ce8a9d4cc3be06fb83acbdc8a3019e2a84bf770903e18b8f1b33",
      "db": 2
    },
    "stats": {
      "port": 6379,
      "host": "redisstats",
      "auth": "57665cc148dc9e9887c7046d9ccaaa9cb4f5b759d9182036d8c81a709d2ef029a3b4dcf431d4ce8a9d4cc3be06fb83acbdc8a3019e2a84bf770903e18b8f1b33",
      "db": 2
    },
    "temp": {
      "port": 6379,
      "host": "redistemp",
      "auth": "57665cc148dc9e9887c7046d9ccaaa9cb4f5b759d9182036d8c81a709d2ef029a3b4dcf431d4ce8a9d4cc3be06fb83acbdc8a3019e2a84bf770903e18b8f1b33",
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