#!/bin/bash

# this script is to be run by mapic cli with docker only

# install packages
echo -n "Preparing packages..."
yarn install >/dev/null 2>&1
echo "done!"

# get default benchmark data
if [ -z $MAPIC_BENCHMARK_DATASET_PATH ]; then
    MAPIC_BENCHMARK_DATASET_PATH=/data/benchmark-data.zip
    if [ ! -f $MAPIC_BENCHMARK_DATASET_PATH ]; then
        cd /data/
        echo -n "Downloading test data..."
        wget https://github.com/mapic/open-data/raw/master/benchmark-data.zip >/dev/null 2>&1
        echo "done!"
    fi
fi

# run benchmark
echo "Warming up..."
node benchmark.js /data/$MAPIC_BENCHMARK_DATASET_PATH
