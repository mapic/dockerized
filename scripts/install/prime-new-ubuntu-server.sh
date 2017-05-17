#!/bin/bash

# settings
DOCKER_COMPOSE_VERSION=1.13.0
DOCKER_MACHINE_VERSION=0.10.0

# update/upgrade
apt update -y
apt upgrade -y

# get tools
apt install -y fish htop wget curl dnsutils host nmap git 

# get more tools
sudo apt-get install -y apt-transport-https ca-certificates software-properties-common

# docker key/repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y

# install docker/compose/machine
sudo apt-get install -y docker-ce
curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://github.com/docker/machine/releases/download/v$DOCKER_MACHINE_VERSION/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine
chmod +x /tmp/docker-machine
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
