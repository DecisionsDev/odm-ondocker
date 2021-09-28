#!/bin/sh

source env-okta-trial.sh

curl -k -u "${client_id}:${client_secret}" \
     -d "token_type_hint=access_token&token=$1" \
     ${introspect_url} | jq

echo ""
