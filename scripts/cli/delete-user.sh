#!/bin/bash

function abort() {
    echo "Error: $1"
    exit 1;
}

# set domain
if [ -z "$MAPIC_DOMAIN" ]; then
    MAPIC_DOMAIN=localhost
fi

# check variables are set
test -z "$1" &&
  abort "Usage: $0 user@domain.com"


# delete localhost user
docker exec -it localhost_engine_1 node scripts/delete_user.js $1 || abort "Failed to delete localhost credentials."
