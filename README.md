# Mapic  

[![GitHub branch](https://img.shields.io/badge/branch-master-blue.svg)](https://github.com/mapic/mapic/tree/master)
[![Build Status](https://travis-ci.org/mapic/mapic.svg?branch=master)](https://travis-ci.org/mapic/mapic)
[![GitHub release](https://img.shields.io/github/release/mapic/mapic.svg)](https://github.com/mapic/mapic/releases) [![Build Status](https://travis-ci.org/mapic/mapic.svg?branch=v2.0)](https://travis-ci.org/mapic/mapic) [![Twitter Follow](https://img.shields.io/twitter/follow/mapic_io.svg?style=social&label=Follow)](https://twitter.com/mapic_io) 

Mapic is an Open Source Web Map Engine. 

Learn more @ https://mapic.io. For a technical overview, see the [wiki](https://github.com/mapic/mapic/wiki/Mapic-Techincal-Overview).



## Install
Begin by installing the Mapic CLI:

```bash
# install mapic cli
curl -sSL https://get.mapic.io  | sh

# show options
mapic

```

This will install and start the Mapic server on `localhost`:
```bash

# configure localhost
mapic domain localhost

# install mapic
mapic install stable

# start mapic
mapic start

```

Install to custom domain:
```bash

# set mapic domain
mapic domain maps.example.com

# install mapic
mapic install stable

```

## Usage

#### Manage Mapic server
```bash
# start server
mapic start

# open web
open https://localhost

# tail logs
mapic logs

# stop mapic server
mapic stop

# restart mapic server
mapic restart
```

#### Interact with Mapic (SDK)
```bash
# create user
mapic user create

# promote to superuser
mapic user super 

# upload data
mapic upload

# see help for more commands and options
mapic help
```

## Depends
- [Docker](https://docs.docker.com/engine/installation/) `>= 1.9.0`  
- [Docker Compose](https://docs.docker.com/compose/install/) `>= 1.5.2`  
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

The Mapic CLI will try to install these automatically on Ubuntu and OSX.

Mapic is built on Docker. Docker images for Mapic are available on the [Docker Hub](https://hub.docker.com/u/mapic/).

## Licence
Mapic is built entirely open source. We believe in a collaborative environment for creating strong solutions for an industry that is constantly moving. The Mapic platform is open for anyone to use and contribute to, which makes it an ideal platform for government organisations and NGO's, as well as for-profit businesses.

Mapic is licenced under the [AGPL licence](https://github.com/mapic/mapic/blob/master/LICENCE).

## Project contributors
- [Frano Cetinic](https://github.com/franocetinic)
- [Jørgen Evil Ekvoll](https://github.com/jorgenevil)
- [Magdalini Fotiadou](https://github.com/mft74)
- [Terrence Lam](https://github.com/skyuplam)
- [Sandro Santilli](https://github.com/strk)
- [Knut Ole Sjøli](https://github.com/knutole)
- [Shahjada Talukdar](https://github.com/destromas1)
- [Igor Ziegler](https://github.com/igorziegler)
