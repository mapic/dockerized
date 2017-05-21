#!/bin/bash
WDR=/usr/src/app
docker run -it -p 80:80 -p 443:443 --env MAPIC_CONFIG_DEBUG --env MAPIC_DOMAIN --env MAPIC_IP --env MAPIC_AWS_ACCESSKEYID --env MAPIC_AWS_SECRETACCESSKEY --env MAPIC_AWS_HOSTED_ZONE_DOMAIN --volume $PWD/dns:$WDR -w $WDR node:4 sh entrypoint.sh