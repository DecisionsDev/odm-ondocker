#!/bin/sh

# https://www.ibm.com/support/knowledgecenter/SSHKN6/iam/3.x.x/apis/oidc_auth_apis.html#get2

token_url=https://cp-console.apps.ocp461dba.cp.fyre.ibm.com/idprovider/v1/auth/identitytoken

client_id=iamclient4odm
client_secret=iamsecret4odm
username=mathias.mouly@fr.ibm.com
password=XXXX

scope=openid

curl -v -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -d "scope=${scope}&grant_type=password&client_id=${client_id}&client_secret=${client_secret}&username=${username}&password=${password}" \
     ${token_url}

echo ""
