
# Mapic [![Build Status](https://travis-ci.org/mapic/mapic.png)](https://travis-ci.org/mapic/mapic)

Mapic is an Open Source Web Map Engine. 

Learn more @ https://mapic.io. For a technical overview, please see [Mapic Technical Overview](https://github.com/mapic/mapic/wiki/Mapic-Techincal-Overview).


## Usage
1. Set enviroment variables: `MAPIC_DOMAIN=domain.example.com` and `$MAPIC_ROOT_FOLDER=/home/mapic`. Exchange values for your domain and installation folder.
2. Install with `mapic install` (or see below).
3. Start server with `mapic start`.
4. Open your browser @ https://localhost.
5. Stop server with `mapic stop`.


## Install

### Install dependencies: 
- [Docker](https://docs.docker.com/engine/installation/) `>= 1.9.0`  
- [Docker Compose](https://docs.docker.com/compose/install/) `>= 1.5.2`  
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Install to localhost
Download install script and run install:
```bash

# download mapic
git clone git://github.com/mapic/mapic.git
cd mapic

# Set enviroment variables
export MAPIC_DOMAIN your.domain.com
export MAPIC_ROOT_FOLDER $PWD

# Then install Mapic
mapic install 

```

### Create User
The first user is created automatically. You can log in to [https://localhost](https://localhost) with these default credentials:  

```
username: localhost@mapic.io
password: localhost-password
```

To create another superuser, do:

```bash
# create super user
cd scripts/api
./create-super-user.sh 

```

### Install to custom domain
Install to localhost first, following instructions above; then see [mapic/config-domain.example.com](https://github.com/mapic/config-domain.example.com) for instructions on changing configs for custom domain.

If installing on a publicly available domain, it's important to flush the default `localhost@mapic.io` superuser account first, for obvious reasons. Simply run this script, and the user is removed:

```bash
# flush localhost user
cd scripts/api
./flush-localhost-user.sh

```

## Libraries
Mapic consists of:   
1. [Mapic Engine](https://github.com/mapic/engine)  
2. [Mapic Mile Tileserver](https://github.com/mapic/mile)    
3. [Mapic Javascript Client library](https://github.com/mapic/mapic.js)    
4. [Mapic SDK](https://github.com/mapic/sdk) (for interacting with API programmatically)

Mapic is built on Docker. Docker Images for Mapic are available on the [Docker Hub](https://hub.docker.com/u/mapic/).

## Licence
Mapic is built entirely open source. We believe in a collaborative environment for creating strong solutions for an industry that is constantly moving. The Mapic platform is open for anyone to use and contribute to, which makes it an ideal platform for government organisations and NGO's, as well as for-profit businesses.

Mapic is licenced under the [AGPL licence](https://github.com/mapic/mapic/blob/master/LICENCE).

## Project contributors
- [Jørgen Evil Ekvoll](https://github.com/jorgenevil)
- [Magdalini Fotiadou](https://github.com/mft74)
- [Terrence Lam](https://github.com/skyuplam)
- [Sandro Santilli](https://github.com/strk)
- [Knut Ole Sjøli](https://github.com/knutole)
- [Shahjada Talukdar](https://github.com/destromas1)
- [Igor Ziegler](https://github.com/igorziegler)
