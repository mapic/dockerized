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

if [ -z "$MAPIC_USER_EMAIL" ]; then
    MAPIC_USER_EMAIL=$(mapic env prompt MAPIC_USER_EMAIL "Please provide a valid email address for the SSL certificate")
fi

if [ -z "$MAPIC_DOMAIN" ]; then
    MAPIC_DOMAIN=$(mapic env prompt MAPIC_DOMAIN "Please provide a valid domain for the SSL certficate")
fi

test -z "$MAPIC_USER_EMAIL" && usage MAPIC_USER_EMAIL # check email
test -z "$MAPIC_DOMAIN" && usage "MAPIC_DOMAIN" # check MAPIC_ROOT_FOLDER is set
    
# certbot-auto
cd $MAPIC_CLI_FOLDER/ssl
certbot certonly \
    --standalone \
    --agree-tos \
    --email "$MAPIC_USER_EMAIL" \
    --hsts \
    --force-renew \
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
   
CERT_PATH=$MAPIC_ROOT_FOLDER/cli/config/files

echo "Created certificates, moving them to $CERT_PATH"
cp /etc/letsencrypt/live/"$MAPIC_DOMAIN"/privkey.pem $CERT_PATH/privkey.key
cp /etc/letsencrypt/live/"$MAPIC_DOMAIN"/fullchain.pem $CERT_PATH/fullchain.pem
