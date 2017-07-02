#!/bin/bash

echo "Initializing submodules..."

# init submodules
cd $MAPIC_ROOT_FOLDER
git submodule init
git submodule update --recursive --remote
git submodule foreach --recursive git checkout master

# install yarn modules
docker run -it --rm -v $MAPIC_ROOT_FOLDER:/mapic_tmp -w /mapic_tmp mapic/xenial:latest yarn install 
