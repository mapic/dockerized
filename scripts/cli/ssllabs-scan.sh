#!/bin/bash

# url
url_to_scan="$1"

# run
docker_opts="--read-only --cap-drop all --rm -it"
image="jumanjiman/ssllabs-scan:latest"
scan_opts="-grade -verbosity info" # see https://github.com/ssllabs/ssllabs-scan#usage
docker run ${docker_opts} ${image} ${scan_opts} ${url_to_scan}