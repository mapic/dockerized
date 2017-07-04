#!/bin/bash
abort () { echo $1; exit 1; }
test -z $MAPIC_CLI && abort "This script must be run from mapic cli. \n Use: mapic ssl create"

# debug mode. usage: command 2>"${PIPE}" 1>"${PIPE}"
if [[ ${MAPIC_DEBUG} = true ]]; then
    PIPE=/dev/stdout
else
    PIPE=/dev/null
fi

# create self-signed SSL certs
echo "# Creating SSL certficate for localhost..."
docker run --rm -it --name openssl \
    -v $MAPIC_CONFIG_FOLDER:/certs \
    wallies/openssl \
    openssl req -x509 -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -keyout /certs/ssl_certificate.key \
        -out /certs/ssl_certificate.pem \
        -subj "/C=NO/ST=Oslo/L=Oslo/O=Mapic/OU=IT Department/CN=localhost" || abort "Failed to create SSL certificates"

# create crypto
echo "Looking for DHParams: $MAPIC_CONFIG_FOLDER"

if  [[ -f "$MAPIC_CONFIG_FOLDER/dhparams.pem" ]]; then
  echo 'Using pre-existing Strong Diffie-Hellmann Group'
else
  echo 'Creating Strong Diffie-Hellmann Group'
  docker run \
    --rm \
    -e "RANDFILE=.rnd" \
    -it \
    --name openssl \
    -v $MAPIC_CONFIG_FOLDER:/certs \
    wallies/openssl \
    openssl dhparam -out /certs/dhparams.pem 2048 || abort "Failed to create Diffie-Hellmann group"
fi