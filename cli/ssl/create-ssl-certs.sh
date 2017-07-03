#!/bin/bash

usage () {
    echo "Missing parameter: $1"
    exit 1
}

abort () {
    echo ""
    echo "Something went wrong. Failed to create SSL certificates."
    echo ""
    echo "Troubleshooting:"
    echo "  PORT 443"
    echo "      Please check that ports 443 are open for INBOUND connections your server,"
    echo "      and that port 443 is not in use."
    echo ""
    exit 1
}


# todo: check if 443 is available, offer to shut down
# put MAPIC_USER_EMAIL somwhere permanently

test -z "$MAPIC_USER_EMAIL" && mapic prompt MAPIC_USER_EMAIL # check email
test -z "$MAPIC_ROOT_FOLDER" && mapic prompt "MAPIC_ROOT_FOLDER" # check MAPIC_ROOT_FOLDER is set
test -z "$MAPIC_DOMAIN" && mapic prompt "MAPIC_DOMAIN" # check MAPIC_ROOT_FOLDER is set

    
# certbot-auto
./certbot certonly \
    --standalone \
    --agree-tos \
    --email "$MAPIC_USER_EMAIL" \
    --hsts \
    --non-interactive \
    --domain "$MAPIC_DOMAIN"           \
    --domain proxy-a-"$MAPIC_DOMAIN"   \
    --domain proxy-b-"$MAPIC_DOMAIN"   \
    --domain proxy-c-"$MAPIC_DOMAIN"   \
    --domain proxy-d-"$MAPIC_DOMAIN"   \
    --domain tiles-a-"$MAPIC_DOMAIN"   \
    --domain tiles-b-"$MAPIC_DOMAIN"   \
    --domain tiles-c-"$MAPIC_DOMAIN"   \
    --domain tiles-d-"$MAPIC_DOMAIN"   \
    --domain  grid-a-"$MAPIC_DOMAIN"   \
    --domain  grid-b-"$MAPIC_DOMAIN"   \
    --domain  grid-c-"$MAPIC_DOMAIN"   \
    --domain  grid-d-"$MAPIC_DOMAIN"   || abort
   
CERT_PATH=$MAPIC_ROOT_FOLDER/config/files

echo "Created certificates, moving them to $CERT_PATH"
cp /etc/letsencrypt/live/"$MAPIC_DOMAIN"/privkey.pem $CERT_PATH/ssl_certificate.key
cp /etc/letsencrypt/live/"$MAPIC_DOMAIN"/fullchain.pem $CERT_PATH/ssl_certificate.pem
