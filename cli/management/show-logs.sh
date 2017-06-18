#!/bin/bash

# get file and name (eg. dev.mapic.io.yml and dev)
# COMPOSEFILE="$MAPIC_ROOT_FOLDER/docker/compose/yml/$MAPIC_DOMAIN".yml
# ARR=(${MAPIC_DOMAIN//./ })
# COMPOSENAME=${MAPIC_DOMAIN//./}

COMPOSEFILE=$MAPIC_CONFIG_FOLDER/mapic.yml
COMPOSENAME=mapic_$MAPIC_DOMAIN

# show logs
docker-compose -f $COMPOSEFILE -p $COMPOSENAME logs -f