#!/bin/sh

export admin_username=<oauthAdmin_login>
export admin_password=<oauthAdmin_password>
export registration_url=https://cp-console.apps.<fyre_master_ip>.nip.io/idauth/oidc/endpoint/OP/registration
export OIDC_CLIENT_ID=<ODM_OIDC_CLIENT_ID>

#curl -k -s -X GET -u ${admin_username}:${admin_password} ${registration_url}
echo "***************"

#curl -u ${admin_username}:${admin_password} --request GET  ${registration_url} --insecure

echo "***************"

curl -u ${admin_username}:${admin_password} --request GET  ${registration_url}/${OIDC_CLIENT_ID} --insecure
