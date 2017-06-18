#!/bin/bash
abort () { echo $1; exit 1; }
test -z $MAPIC_CLI && abort "This script must be run from mapic cli. Use: mapic create_storage (#todo!)"

# debug mode. usage: command 2>"${PIPE}" 1>"${PIPE}"
if [[ ${MAPIC_DEBUG} = true ]]; then
    PIPE=/dev/stdout
else
    PIPE=/dev/null
fi


echo "# Creating storage containers..."
docker run \
    -it \
    --rm \
    --name create-containers \
    -v "$MAPIC_CLI_FOLDER/install":/cli \
    -v "$MAPIC_ROOT_FOLDER/cli/config/files":/config \
    -w /cli \
    --env-file "$MAPIC_ENV_FILE" \
    node:6 \
    node create-storage-containers.js
    # node create-storage-containers.js 2>"${PIPE}" 1>"${PIPE}"

# bash createcontainers.tmp.sh 2>"${PIPE}" 1>"${PIPE}"
# rm -f createcontainers.tmp.sh 2>"${PIPE}" 1>"${PIPE}"
bash createcontainers.tmp.sh
rm -f createcontainers.tmp.sh
