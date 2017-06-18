#!/bin/bash

function abort() {
    echo $1
    exit 1;
}

# check domain ENV is set
# todo: move checks to cli
[ -z "$MAPIC_DOMAIN" ] && abort "Flush failed! Need to set MAPIC_DOMAIN, eg: 'mapic env set MAPIC_DOMAIN localhost'"

# get name
COMPOSEFILE=$MAPIC_CONFIG_FOLDER/mapic.yml
COMPOSENAME=mapic$MAPIC_DOMAIN

# remove stale containers
docker rm "$COMPOSENAME"_nginx_1
docker rm "$COMPOSENAME"_mile_1
docker rm "$COMPOSENAME"_engine_1
docker rm "$COMPOSENAME"_redislayers_1
docker rm "$COMPOSENAME"_redisstats_1
docker rm "$COMPOSENAME"_redistemp_1
docker rm "$COMPOSENAME"_mongo_1
docker rm "$COMPOSENAME"_postgis_1
