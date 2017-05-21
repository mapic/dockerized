#!/bin/bash
MAPIC_ROOT_FOLDER=/mapic 
MAPIC_DOMAIN=dev.mapic.io
MAPIC_CONFIG=$MAPIC_ROOT_FOLDER/config/$MAPIC_DOMAIN
BASHRC=$HOME/.bashrc # nb: https://superuser.com/questions/484277/get-home-directory-by-username#comment1254323_854196


echo "export MAPIC_ROOT_FOLDER=$MAPIC_ROOT_FOLDER" >> $BASHRC
echo "export MAPIC_DOMAIN=$MAPIC_DOMAIN" >> $BASHRC
echo "export MAPIC_CONFIG=$MAPIC_CONFIG" >> $BASHRC