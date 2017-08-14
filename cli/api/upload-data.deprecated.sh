#!/bin/bash

fail () {
    echo $1
    exit 1
}

check_env () {

    echo "checking env"

    # allow arg for dataset
    if [ -n $3 ]; then
        MAPIC_API_UPLOAD_DATASET=$3
        mapic config set MAPIC_API_UPLOAD_DATASET "$3"
    fi
    # test -n $3 && mapic env set --quiet MAPIC_API_UPLOAD_DATASET $3; MAPIC_API_UPLOAD_DATASET=$3

    echo "checking more"

    # check for all variables
    test -z $MAPIC_API_DOMAIN                && mapic config prompt MAPIC_API_DOMAIN "Enter the domain for Mapic API" $MAPIC_DOMAIN
    test -z $MAPIC_API_UPLOAD_DATASET        && mapic config prompt MAPIC_API_UPLOAD_DATASET "Enter absolute path of your dataset"
    test -z $MAPIC_API_UPLOAD_PROJECT        && mapic config prompt MAPIC_API_UPLOAD_PROJECT "Enter ID of your project (or leave blank to create new project)"
    test -z $MAPIC_API_PROJECT_NEW_TITLE     && mapic config prompt MAPIC_API_PROJECT_NEW_TITLE "Enter title for your new project (or leave blank)"
    test -z $MAPIC_API_DATASET_TITLE         && mapic config prompt MAPIC_API_DATASET_TITLE "Enter title of dataset (will default to file name)"
    test -z $MAPIC_API_USERNAME              && mapic config prompt MAPIC_API_USERNAME "Enter your Mapic API username or email"
    test -z $MAPIC_API_AUTH                  && mapic config prompt MAPIC_API_AUTH "Enter your Mapic API password"

    echo "checking debug"

    # debug
    if [[ "$MAPIC_DEBUG" == "true" ]]; then
        echo "MAPIC_API_DOMAIN            $MAPIC_API_DOMAIN            "
        echo "MAPIC_API_UPLOAD_DATASET    $MAPIC_API_UPLOAD_DATASET    "
        echo "MAPIC_API_UPLOAD_PROJECT    $MAPIC_API_UPLOAD_PROJECT    "
        echo "MAPIC_API_PROJECT_NEW_TITLE $MAPIC_API_PROJECT_NEW_TITLE "
        echo "MAPIC_API_DATASET_TITLE     $MAPIC_API_DATASET_TITLE     "
        echo "MAPIC_API_USERNAME          $MAPIC_API_USERNAME          "
        echo "MAPIC_API_AUTH              $MAPIC_API_AUTH              "
        echo "MAPIC_API_DEBUG             $MAPIC_API_DEBUG             "
        echo "DAEMON:                     $DAEMON"
        echo "IMAGE:                      $IMAGE"
        echo "CMD:                        $CMD"
        echo "WORKDIR:                    $WORKDIR"
        echo "PWD:                        $PWD"
        echo "ENV_FILE:                   $ENV_FILE"
    fi

}

# run settings
WORKDIR="/tmp"
ENV_FILE=$(mapic env file)
# API_DIR=$MAPIC_ROOT_FOLDER/api

docker_run () {

    echo "run"

    # install npm packages
    docker run -it --volume $PWD:$WORKDIR --workdir $WORKDIR node:slim npm install --silent || fail "Couldn't install Node modules"

    echo "up"
    # upload data
    docker run -it --volume $PWD:$WORKDIR --volume $MAPIC_API_UPLOAD_DATASET:/mapic_upload$MAPIC_API_UPLOAD_DATASET --workdir $WORKDIR --env-file $MAPIC_ENV_FILE node:slim node upload-data.js || fail "Couldn't upload dataset: $@"
}

check_env "$@"
docker_run



