#!/bin/bash

# helper fn
print_log () {
    echo ""
    echo "$1"
    echo ":::::::::::::::::::::::::::::::::"
    echo ""
}

# helper fn
abort () {
    exit $1
}

# get working dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# get flags
FLAG=$1

# clear 
clear
                                                                                                                                                                  
# print
print_log "Installing Mapic to localhost..."
print_log "# Current working directory: $DIR"
print_log "# Downloading code..."

# set env
export MAPIC_DOMAIN=localhost

# init mapic/mapic submodule
cd $DIR
git submodule init
git submodule update --recursive --remote
git submodule foreach --recursive git checkout master

# init mapic/mile submodule
cd $DIR/modules/mile
git submodule init
git submodule update --recursive --remote

# init mapic/engine submodule
cd $DIR/modules/engine
git submodule init
git submodule update --recursive --remote

# init mapic/mapic.js submodule
cd $DIR/modules/mapic.js
git submodule init
git submodule update --recursive --remote

# init mapic/sdk submodule
cd $DIR/modules/sdk
git submodule init
git submodule update --recursive --remote

# install modules in mapic/mapic (for scripts, etc)
cd $DIR
npm install

# create self-signed SSL certs
print_log "# Creating SSL certficate..."
docker run --rm -it --name openssl \
    -v $DIR/config/localhost:/certs \
    wallies/openssl \
    openssl req -x509 -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -keyout /certs/ssl_certificate.key \
        -out /certs/ssl_certificate.pem \
        -subj "/C=NO/ST=Oslo/L=Oslo/O=Mapic/OU=IT Department/CN=localhost"

# update config
print_log "# Updating configuration..."
cd $DIR/scripts/install
node update-configs.js $MAPIC_DOMAIN

# create storage containers
print_log "# Creating storage containers..."
cd $DIR/docker/compose/
./create-storage-containers.sh

# init mongo
print_log "# Initializing Mongo database"
docker run -v $DIR/config/${MAPIC_DOMAIN}:/mapic/config --volumes-from mapic_mongo_store_localhost -it mapic/mongo:latest /init.sh




###
## travis
###
#
# for mapic/mapic, do install-to-localhost.sh script
# for mapic/engine, mapic/mile, mapic/mapic.js, do standalone travis-install.sh script, w/o localhost script
# that way, both localhost-install is tested, while full control of checkouts of other code
# 

# exit if travis
echo "TRAVIS ENV travis_repo=$travis_repo"
if [ -v "$travis_repo" ]; then
    exit
fi





## normal localhost install continues here:
## ----------------------------------------
# install node modules
# print_log "# Installing Node modules"
# todo: move this to respective start-server scripts
cd $DIR
print_log "Installing Mapic Tile Server"
docker run -v $DIR/config/${MAPIC_DOMAIN}:/mapic/config -v $DIR/modules:/mapic/modules -w /mapic/modules/mile -it mapic/mile:latest npm install --loglevel=silent 
print_log "Installing Mapic Engine"
docker run -v $DIR/config/${MAPIC_DOMAIN}:/mapic/config -v $DIR/modules:/mapic/modules -w /mapic/modules/engine -it mapic/engine:latest npm install --loglevel=silent
print_log "Installing Mapic.js"
docker run -v $DIR/config/${MAPIC_DOMAIN}:/mapic/config -v $DIR/modules:/mapic/modules -w /mapic/modules/mapic.js -it mapic/engine:latest npm install --loglevel=silent

# start server
print_log "# Starting Mapic server..."
cd $DIR/docker/compose/
./start-containers.sh --no-logs

# run tests
print_log "# Running tests..."
sleep 30
cd $DIR/scripts/test
./run-localhost-tests.sh || abort

# show logs
print_log "# Opening logs..."
cd $DIR/docker/compose/
./show-logs.sh
