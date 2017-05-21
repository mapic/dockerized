#!/bin/bash


usage () {
    echo "Usage: ./create-storage-containers.sh YOURDOMAIN"
    exit 1
}
no_args () {
    [ -z "$MAPIC_DOMAIN" ] && usage
    # continue
}
abort () {
    echo ""
    echo "Something went wrong. Aborting!"
    exit 1
}

# check for proper usage
[ -z "$1" ] && no_args

echo "Preparing to create storage containers..."
docker run -it --rm --name create-containers -v "$PWD":/usr/src/app -w /usr/src/app --env MAPIC_DOMAIN node:4 node .storage-script-helper.js || abort

echo "Creating storage containers..."
sh createcontainers.tmp.sh 2> /dev/null || abort

# cleanup
echo "Storage containers created!"
rm -f createcontainers.tmp.sh
