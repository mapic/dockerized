#!/bin/bash

# this script is to be run by mapic cli with docker only

# install packages
yarn install >/dev/null 2>&1

# get benchmark data
BENCHMARKDATA=benchmark-data.zip
if [ ! -f $BENCHMARKDATA ]; then
    wget https://github.com/mapic/open-data/raw/master/$BENCHMARKDATA >/dev/null 2>&1
fi

# run benchmark
node benchmark.js $BENCHMARKDATA
