#!/bin/bash

# install node modules
npm --loglevel=silent install 2>&1 >/dev/null

# run node script
node dns-helper.js

# cleanup
rm -r node_modules/