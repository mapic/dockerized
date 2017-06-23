#!/bin/bash

COMPOSEFILE=$MAPIC_CONFIG_FOLDER/stack.yml
# COMPOSENAME=mapic_$MAPIC_DOMAIN

# cd $MAPIC_CONFIG_FOLDER   
docker stack rm mapic
docker stack deploy --compose-file=$COMPOSEFILE mapic 