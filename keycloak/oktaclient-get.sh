#!/bin/sh

source env-okta-trial.sh

echo "${registration_url}/${client_id}"
curl \
     -H "Accept: application/json" \
     -H "Content-Type:application/json" \
     -H "Authorization: SSWS ${api_token}" \
     "${registration_url}/${client_id}" | jq
