#!/bin/bash

# install docker community edition
# updated May 12th 2017
#
# https://docs.docker.com/engine/installation/linux/ubuntu/

DOCKER_COMPOSE_VERSION=1.13.0
DOCKER_MACHINE_VERSION=0.10.0
DOCKER_CE_VERSION=17.03

# remove old docker versions
sudo apt-get remove -y docker docker-engine docker-ce

# install deps
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# get key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add repo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update -y

# install docker-ce
sudo apt-get install -y docker-ce=$DOCKER_CE_VERSION

# install docker-compose
curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install docker machine
curl -L https://github.com/docker/machine/releases/download/v$DOCKER_MACHINE_VERSION/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

# verify version
clear
echo "Installed Docker Community Edition and Docker Compose:"
echo "Docker version:"
docker version
echo "Docker Compose version:"
docker-compose version
echo "Docker Machine version:"
docker-machine version