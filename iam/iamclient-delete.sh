#!/bin/sh

export admin_username=oauthadmin
export admin_password=fVcsk0mHoNWCoqQUszWnpNNKXCYQxbdc
export registration_url=https://cp-console.apps.9.20.212.178.nip.io/idauth/oidc/endpoint/OP/registration
export OIDC_CLIENT_ID=icp4aodm-prod-odm-oidc-client-id

#curl -k -s -X GET -u ${admin_username}:${admin_password} ${registration_url}
echo "***************"

#curl -u ${admin_username}:${admin_password} --request GET  ${registration_url} --insecure

echo "***************"

curl -u ${admin_username}:${admin_password} --request DELETE  ${registration_url}/${OIDC_CLIENT_ID} --insecure
