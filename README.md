<p align="center">
    <img width="300px" src="https://user-images.githubusercontent.com/2197944/27542704-5e1f18c6-5a88-11e7-96bb-9e36ca6e4c93.png">
</p>
<p align="center">
    <a href="https://github.com/mapic/mapic/releases"><img src="https://img.shields.io/github/release/mapic/mapic.svg" alt="Downloads"></a>
    <a href="https://travis-ci.org/mapic/mapic/branches"><img src="https://travis-ci.org/mapic/mapic.svg?branch=v2.0.1" alt="Downloads"></a>
    <a href="https://travis-ci.org/mapic/mapic/builds"><img src="https://img.shields.io/travis/mapic/mapic/master.svg?branch=master&label=build%20@%20master" alt="Downloads"></a>
    <a href="https://snyk.io/test/github/mapic/mapic"><img src="https://snyk.io/test/github/mapic/mapic/badge.svg" alt="Known Vulnerabilities" data-canonical-src="https://snyk.io/test/github/mapic/mapic" style="max-width:100%;"/></a>
    <a href="https://www.codacy.com/app/knutole/mapic?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=mapic/mapic&amp;utm_campaign=Badge_Grade"><img src="https://api.codacy.com/project/badge/Grade/2937e86810b247e9966505c7ba4bac5f"/></a>
    <a href="https://twitter.com/mapic_io"><img src="https://img.shields.io/twitter/follow/mapic_io.svg?style=social&label=Follow" alt="Downloads"></a>
</p>
<p align="center">
    Mapic is an Open Source Web Map Engine.
</p>
<p align="center">
    Learn more @ https://mapic.io. For a technical overview, see the <a href="https://github.com/mapic/mapic/wiki/Mapic-Techincal-Overview">wiki</a>.
</p>

## Install

### Install the Mapic CLI:
On OSX or Ubuntu:

```bash
# install mapic cli
curl -sSL https://get.mapic.io  | sh

# enter folder
cd mapic

# run global mapic cli command
mapic

```

### Install and start on localhost:
```bash

# configure localhost
mapic domain localhost

# install latest stable mapic
mapic install stable

# configure
mapic configure

# start mapic
mapic start

```

## Usage

### Manage Mapic server
Commands for managing the Mapic server. See `mapic help` for all options.

```bash
# start server
mapic start

# open web
open https://localhost

# show logs
mapic logs

# tail logs
mapic logs postgis

# stop mapic server
mapic stop

# restart mapic server
mapic restart

```

### Interact with the Mapic API
Commands for interacting with any running Mapic server's API. 
```bash
# create user
mapic api user create

# promote to superuser
mapic api user super 

# upload data
mapic api upload

# see help for more commands and options
mapic api help
```

## Depends
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Docker](https://docs.docker.com/engine/installation/) 
- [Docker Machine](https://docs.docker.com/machine/install-machine/)

The Mapic CLI will attempt to install these automatically on Ubuntu and OSX.

Mapic is built with Docker. Docker images for Mapic are available on the [Docker Hub](https://hub.docker.com/u/mapic/).


## Licence 
Mapic is built entirely open source. We believe in a collaborative environment for creating strong solutions for an industry that is constantly moving. The Mapic platform is open for anyone to use and contribute to, which makes it an ideal platform for government organisations and NGO's, as well as for-profit businesses.

Mapic is licensed under the [AGPL licence](https://github.com/mapic/mapic/blob/master/LICENCE).

## Project contributors
- [Frano Cetinic](https://github.com/franocetinic)
- [Jørgen Evil Ekvoll](https://github.com/jorgenevil)
- [Magdalini Fotiadou](https://github.com/mft74)
- [Terrence Lam](https://github.com/skyuplam)
- [Sandro Santilli](https://github.com/strk)
- [Knut Ole Sjøli](https://github.com/knutole)
- [Shahjada Talukdar](https://github.com/destromas1)
- [Igor Ziegler](https://github.com/igorziegler)
