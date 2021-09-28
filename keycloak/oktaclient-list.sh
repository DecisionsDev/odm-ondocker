#!/bin/sh

source env-okta-trial.sh

curl \
     -H "Accept: application/json" \
     -H "Content-Type:application/json" \
     -H "Authorization: bearer $1" \
     "${registration_url}" | jq
