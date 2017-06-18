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

# check for existing version
# DOCKER_EXISTING=$(docker version)
# echo "DOCKER_EXISTING: $DOCKER_EXISTING"

# exit 0


# # remove old docker versions
# sudo apt-get -qq remove -y docker docker-engine

# # install deps
# echo "Installing dependencies"
# sudo apt-get -qq install -y \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     software-properties-common

# # get key
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# # add repo
# sudo add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"
# sudo apt-get -qq update -y

# # install docker-ce
# echo "Installing Docker"
# sudo apt-get -qq install -y docker-ce


# install docker from pkg
CODENAME=$(lsb_release -cs)
echo "CODENAME: $CODENAME"
PKG="docker-ce_17.03.0~ce-0~ubuntu-"$CODENAME"_amd64.deb"
echo "PKG: $PKG"
curl -L https://download.docker.com/linux/ubuntu/dists/$CODENAME/pool/stable/amd64/$PKG > /tmp/$PKG | abort "Couldn't download $PKG"
ls /tmp
sudo dpkg -i /tmp/$PKG

# install docker-compose
echo "Installing Docker Compose"
curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install docker machine
echo "Installing Docker Machine"
curl -L https://github.com/docker/machine/releases/download/v$DOCKER_MACHINE_VERSION/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

# verify version
# clear
# echo "Installed Docker Community Edition and Docker Compose:"
# echo "Docker version:"
# docker version
# echo "Docker Compose version:"
# docker-compose version
# echo "Docker Machine version:"
# docker-machine version