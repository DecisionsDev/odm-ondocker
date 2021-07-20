#!/bin/sh

# https://www.ibm.com/support/knowledgecenter/SSHKN6/iam/3.x.x/apis/oidc_auth_apis.html#get2

token_url=https://cp-console.apps.9.20.212.178.nip.io/idprovider/v1/auth/identitytoken

export client_secret=ibm-odm-vtt-odm-oidc-client-id-secret-value
export client_id=ibm-odm-vtt-odm-oidc-client-id
username=odmAdmin
password=odmAdmin

scope=openid

curl -v -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -d "scope=${scope}&grant_type=password&client_id=${client_id}&client_secret=${client_secret}&username=${username}&password=${password}" \
     ${token_url}

echo ""
