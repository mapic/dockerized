#!/bin/bash

# download mapic/mapic
git clone git://github.com/mapic/mapic.git
cd mapic # todo $MAPIC_ROOT_FOLDER

# download mapic/mapic
cd $MAPIC_ROOT_FOLDER
git submodule init
git submodule update --recursive --remote
git submodule foreach --recursive git checkout master

# init mapic/mile submodule
cd $MAPIC_ROOT_FOLDER/modules/mile
git submodule init
git submodule update --recursive --remote

# init mapic/engine submodule
cd $MAPIC_ROOT_FOLDER/modules/engine
git submodule init
git submodule update --recursive --remote

# init mapic/mapic.js submodule
cd $MAPIC_ROOT_FOLDER/modules/mapic.js
git submodule init
git submodule update --recursive --remote

# init mapic/sdk submodule
cd $MAPIC_ROOT_FOLDER/modules/sdk
git submodule init
git submodule update --recursive --remote