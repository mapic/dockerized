#!/bin/bash

fail () {
    echo "$@"
    exit 1
}

# get file and name (eg. dev.mapic.io.yml and dev)]
# cd $MAPIC_ROOT_FOLDER/docker/compose
# COMPOSEFILE="yml/$MAPIC_DOMAIN".yml
# COMPOSENAME=${MAPIC_DOMAIN//./}
COMPOSEFILE=$MAPIC_CONFIG_FOLDER/mapic.yml
COMPOSENAME=mapic_$MAPIC_DOMAIN

# stop containers
docker-compose -f $COMPOSEFILE -p $COMPOSENAME kill

echo ""
echo "Mapic is stopped."