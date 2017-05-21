#!/bin/bash
cd yml
docker stack rm mapic
docker stack deploy --compose-file=dev.mapic.io.yml mapic