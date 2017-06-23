#!/bin/bash

# COMPOSEFILE=$MAPIC_CONFIG_FOLDER/mapic.yml
# COMPOSENAME=mapic_$MAPIC_DOMAIN

# # show logs
# docker-compose -f $COMPOSEFILE -p $COMPOSENAME logs -f


docker service logs -f mapic_mile         &
docker service logs -f mapic_postgis      &
docker service logs -f mapic_redistokens  &
docker service logs -f mapic_redislayers  &
docker service logs -f mapic_mongo        &
docker service logs -f mapic_redisstats   &
docker service logs -f mapic_nginx        &
docker service logs -f mapic_engine       &
docker service logs -f mapic_redistemp    & 