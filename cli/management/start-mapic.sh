#!/bin/bash

fail () {
    echo "$@"
    exit 1
}

# get file and name (eg. dev.mapic.io.yml and dev)
COMPOSEFILE=$MAPIC_CONFIG_FOLDER/mapic.yml
COMPOSENAME=mapic_$MAPIC_DOMAIN

echo "COMPOSENAME $COMPOSENAME"
echo "COMPOSEFILE $COMPOSEFILE"

# start
docker-compose -v
docker-compose -f $COMPOSEFILE -p $COMPOSENAME up -d || fail "Couldn't start Mapic."

echo ""
echo "Mapic is up and running @ https://$MAPIC_DOMAIN"