#!/bin/bash

function abort() {
    echo "Error: $1"
    exit 1;
}

# set domain
if [ -z "$MAPIC_DOMAIN" ]; then
    MAPIC_DOMAIN=localhost
fi

# delete localhost user
docker exec -it localhost_engine_1 node scripts/delete_user.js localhost@mapic.io || abort "Failed to delete localhost credentials. Are you sure the portal is running?"
