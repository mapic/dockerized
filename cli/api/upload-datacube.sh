#!/bin/bash

docker run -v $PWD:/sdk/ -v /:/data --env-file $(mapic config file) -it node node /sdk/upload_datacube.js $1
