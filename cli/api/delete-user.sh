#!/bin/bash

fail () {
    echo "Error: $1  Ensure Mapic is running!"
    exit 1;
}

# delete user
mapic run engine node --no-deprecation scripts/delete_user.js "$@" || fail
