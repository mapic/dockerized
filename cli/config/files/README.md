# Config files for  `localhost`

## Install
1. Run [`install-to-localhost.sh`](https://github.com/mapic/mapic/blob/master/install-to-localhost.sh) from [`mapic/mapic`](https://github.com/mapic/mapic) root folder.
2. Start your engines! `./restart-mapic.sh` from `/mapic/` root folder

## Manual install
1. Clone repo to `config/` folder in [`mapic`](https://github.com/mapic/mapic) root: `cd config && git clone git@github.com:mapic/config-localhost.git localhost`
2. Make sure folder is named `localhost` (not `config-localhost`)
3. [Set ENV variable](https://www.schrodinger.com/kb/1842) `MAPIC_DOMAIN` to `localhost`.
4. Update the config files (see overview below).
5. Start your engines! `./restart-mapic.sh` from `/mapic/` root folder

## List of config files 

| Config file                                 |        Purpose            |   What to update
| --------------------------------------------|---------------------------|-------------------------------| 
| domain.example.com.nginx.conf               | NginX server config       |   Domain names                |
| mongo.json                                  | MongoDB settings          |   MongoDB access details      |
| redis.layers.conf                           | Redis config              |   Access details              |
| redis.stats.conf                            | Redis config              |   Access details              |
| redis.temp.conf                             | Redis config              |   Access details              |
| redis.tokens.conf                           | Redis config              |   Access details              |
| engine.config.js                            | Redis config              |   Access details              |
| mile.config.js                              | Mile config               |   Mongo/redis access details  |
| env.sh                                      | PostGIS settings          |   PostGIS access details      | 
|                                             |                           |                               |
| mongod.conf                                 | MongoDB config            |   Nothing, defaults good      |
| ssl_certificate.key                         | SSL Certificate           |   Create your own             | 
| ssl_certificate.pem                         | SSL Certificate           |   Create your own             |
| dhparams.pem                                | DH params for SSL         |   Nothing (auto-generated)    |
| nginx.conf -> domain.example.com.nginx.conf | Symlink to nginx config   |   Point to nginx config       |

