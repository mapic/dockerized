#!/bin/bash

# install docker community edition
# updated May 12th 2017
# https://docs.docker.com/engine/installation/linux/ubuntu/
#
# todo: compare installed versions with latest and update

abort () {
    echo $1
    exit 1
}

# get releases live from github
DOCKER_COMPOSE_LATEST=$(docker run mapic/tools /bin/sh -c "curl -L -s -H 'Accept: application/json' https://github.com/docker/compose/releases/latest")
DOCKER_MACHINE_LATEST=$(docker run mapic/tools /bin/sh -c "curl -L -s -H 'Accept: application/json' https://github.com/docker/machine/releases/latest")
DOCKER_COMPOSE_VERSION=$(echo $DOCKER_COMPOSE_LATEST | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
DOCKER_MACHINE_VERSION=$(echo $DOCKER_MACHINE_LATEST | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

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
    curl -L https://github.com/docker/machine/releases/download/$DOCKER_MACHINE_VERSION/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine
    chmod +x /tmp/docker-machine
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
    DOCKER_VERSION=$(docker-machine -v)
    echo "$DOCKER_VERSION installed"
fi
