#!/bin/sh

introspect_url=https://cp-console.apps.9.20.212.178.nip.io/idprovider/v1/auth/introspect

export client_secret=ibm-odm-vtt-odm-oidc-client-id-secret-value
export client_id=ibm-odm-vtt-odm-oidc-client-id
curl -k -u "${client_id}:${client_secret}" \
     -d "token_type_hint=access_token&token=$1" \
     ${introspect_url} | jq

echo ""
