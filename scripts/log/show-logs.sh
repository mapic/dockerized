#!/bin/bash

# allow first arg for domain
test -n "$1" && MAPIC_DOMAIN=`echo "$1" | sed 's/\.yml$//'`

# set mapic domain
test -z "$MAPIC_DOMAIN" &&
    MAPIC_DOMAIN=localhost

# export env
export MAPIC_DOMAIN
export MAPIC_ROOT_FOLDER

# get file and name (eg. dev.mapic.io.yml and dev)
COMPOSEFILE="$MAPIC_ROOT_FOLDER/docker/compose/yml/$MAPIC_DOMAIN".yml
ARR=(${MAPIC_DOMAIN//./ })
COMPOSENAME=${MAPIC_DOMAIN//./}

# show logs
docker-compose -f $COMPOSEFILE -p $COMPOSENAME logs -f