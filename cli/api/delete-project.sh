#!/bin/bash

fail () {
    echo "Error: $1  Ensure Mapic is running!"
    exit 1;
}

echo "4: $4"

# list users
mapic run engine node --no-deprecation scripts/delete_project.js $4 || fail
