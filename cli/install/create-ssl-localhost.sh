#!/bin/bash
abort () { echo $1; exit $1; }
test -z $MAPIC_CLI && abort "This script must be run from mapic cli. Use: mapic install ssl (#todo!)"

# debug mode. usage: command 2>"${PIPE}" 1>"${PIPE}"
if [[ ${MAPIC_DEBUG} = true ]]; then
    PIPE=/dev/stdout
else
    PIPE=/dev/null
fi


# create self-signed SSL certs
echo "# Creating SSL certficate for localhost..."
docker run --rm -it --name openssl \
    -v $MAPIC_ROOT_FOLDER/cli/config/files:/certs \
    wallies/openssl \
    openssl req -x509 -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -keyout /certs/ssl_certificate.key \
        -out /certs/ssl_certificate.pem \
        -subj "/C=NO/ST=Oslo/L=Oslo/O=Mapic/OU=IT Department/CN=localhost"
        # -subj "/C=NO/ST=Oslo/L=Oslo/O=Mapic/OU=IT Department/CN=localhost" 2>"${PIPE}" 1>"${PIPE}"
