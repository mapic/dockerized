#!/bin/bash

fail () {
    echo "Error: $1  Ensure Mapic is running!"
    exit 1;
}

# list users
mapic run engine node --no-deprecation scripts/list_projects.js || fail
