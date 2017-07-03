#!/bin/bash

fail () {
    echo "$@"
    exit 1
}

# get file and name (eg. dev.mapic.io.yml and dev)]
COMPOSEFILE=$MAPIC_CONFIG_FOLDER/mapic.yml
COMPOSENAME=mapic_$MAPIC_DOMAIN

# stop containers
docker-compose -f $COMPOSEFILE -p $COMPOSENAME kill

echo ""
echo "Mapic is stopped."
