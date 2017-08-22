#!/bin/bash

abort () {
    echo $1
    exit 1
}

# install docker community edition
# updated May 12th 2017
#
# https://docs.docker.com/engine/installation/linux/ubuntu/

# todo: track docker versions elsewhere, connected to git release tag
DOCKER_COMPOSE_VERSION=1.13.0
DOCKER_MACHINE_VERSION=0.10.0

command_exists () {
    command -v "$@" > /dev/null 2>&1
}

# check for docker
if command_exists docker; then
    DOCKER_VERSION=$(docker -v)
    echo "$DOCKER_VERSION already installed"
else 
    # install docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update -y
    apt-cache policy docker-ce
    sudo apt-get -f install
    sudo apt-get install -y docker-ce
    DOCKER_VERSION=$(docker -v)
    echo "$DOCKER_VERSION installed"
fi

# check for docker-compose
if command_exists docker-compose; then
    DOCKER_VERSION=$(docker-compose -v)
    echo "$DOCKER_VERSION already installed"
else 
    # install docker-compose
    echo "Installing Docker Compose"
    curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    DOCKER_VERSION=$(docker-compose -v)
    echo "$DOCKER_VERSION installed"
fi

# check for docker-machine
if command_exists docker-machine; then
    DOCKER_VERSION=$(docker-machine -v)
    echo "$DOCKER_VERSION already installed"
else 
    # install docker machine
    echo "Installing Docker Machine"
    curl -L https://github.com/docker/machine/releases/download/v$DOCKER_MACHINE_VERSION/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine
    chmod +x /tmp/docker-machine
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
    DOCKER_VERSION=$(docker-machine -v)
    echo "$DOCKER_VERSION installed"
fi
