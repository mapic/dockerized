#!/bin/bash

docker service logs -f mapic_mile         &
docker service logs -f mapic_postgis      &
docker service logs -f mapic_redistokens  &
docker service logs -f mapic_redislayers  &
docker service logs -f mapic_mongo        &
docker service logs -f mapic_redisstats   &
docker service logs -f mapic_nginx        &
docker service logs -f mapic_engine       &
docker service logs -f mapic_redistemp    &