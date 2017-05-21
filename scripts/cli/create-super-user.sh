#!/bin/bash


function abort() {
    echo "Error: $1  Ensure the Mapic portal is running!"
    exit 1;
}


# set domain
if [ -z "$MAPIC_DOMAIN" ]; then
    MAPIC_DOMAIN=localhost
fi

MAPIC_DOMAIN="${MAPIC_DOMAIN//./}"

# check variables are set
test -z "$1" &&
  abort "Usage: $0 user@domain.com username firstName lastName [password]"

test -z "$2" &&
  abort "Usage: $0 user@domain.com username firstName lastName [password]"

test -z "$3" &&
  abort "Usage: $0 user@domain.com username firstName lastName [password]"

test -z "$4" &&
  abort "Usage: $0 user@domain.com username firstName lastName [password]"


# create user
docker exec -it ${MAPIC_DOMAIN}_engine_1 node scripts/create_user.js $1 $2 $3 $4 $5 || abort "Failed to create user."

# make superadmin
docker exec -it ${MAPIC_DOMAIN}_engine_1 node scripts/make_super.js $1 || abort "Failed to make superadmin."