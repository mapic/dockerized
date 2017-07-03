module.exports = {
  "port": 3003,
  "redis": {
    "layers": {
      "port": 6379,
      "host": "redislayers",
      "auth": "8687eb298aa834637669e3569792598deabb795080be69cfc353497bc550eaacceee067cd90a92e514dced701de4d1d517d775238537aeadda0dbade9380f3f9",
      "db": 2
    },
    "stats": {
      "port": 6379,
      "host": "redisstats",
      "auth": "8687eb298aa834637669e3569792598deabb795080be69cfc353497bc550eaacceee067cd90a92e514dced701de4d1d517d775238537aeadda0dbade9380f3f9",
      "db": 2
    },
    "temp": {
      "port": 6379,
      "host": "redistemp",
      "auth": "8687eb298aa834637669e3569792598deabb795080be69cfc353497bc550eaacceee067cd90a92e514dced701de4d1d517d775238537aeadda0dbade9380f3f9",
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