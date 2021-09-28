#!/bin/sh

source env-okta-trial.sh

scope=openid

curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -d "scope=${scope}&grant_type=password&client_id=${client_id}&client_secret=${client_secret}&username=${username}&password=${password}" \
     ${token_url} | jq

echo ""
