#!/bin/bash

# get mongo volume
MONGO_VOLUME=$(docker ps -q --filter name=mongo)
echo $MONGO_VOLUME

# stop mapic
mapic stop

# run config scripts
docker run -it \
    --env MAPIC_DOMAIN=$MAPIC_DOMAIN \
    --env MAPIC_ROOT_FOLDER=$MAPIC_ROOT_FOLDER \
    --env MAPIC_CONFIG_FOLDER=$MAPIC_CONFIG_FOLDER \
    --volume $MAPIC_ROOT_FOLDER:$MAPIC_ROOT_FOLDER \
    -w $MAPIC_ROOT_FOLDER \
    node:4 node scripts/cli/config/configure-mapic.js 

# start mapic
mapic start