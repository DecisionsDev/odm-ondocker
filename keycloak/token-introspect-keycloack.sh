#!/bin/sh

source env-okta-trial.sh

curl -k \
     -d "client_secret=${client_secret}&client_id=${client_id}&username=mathias&token=$1" \
     ${introspect_url} | jq

echo ""
