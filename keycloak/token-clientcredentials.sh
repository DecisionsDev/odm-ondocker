#!/bin/bash

source env-keycloak-trial.sh

scope=openid

curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -d "scope=${scope}&grant_type=client_credentials&client_id=${client_id}&client_secret=${client_secret}" \
     ${token_url} | jq

echo ""
