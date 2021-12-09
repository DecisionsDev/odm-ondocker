#!/bin/sh

source env-okta-trial.sh

curl -X DELETE \
     -H "Accept: application/json" \
     -H "Content-Type:application/json" \
     -H "Authorization: SSWS ${api_token}" \
     "${registration_url}/${client_id}" | jq
