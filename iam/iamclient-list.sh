#!/bin/sh

***REMOVED***
export admin_password=1k1KE0U3qOfeNVnR9kajp22zQud0Byat 
export registration_url=https://cp-console.apps.ocp461dba.cp.fyre.ibm.com/idauth/oidc/endpoint/OP/registration
export OIDC_CLIENT_ID=iamclient4odm

#curl -k -s -X GET -u ${admin_username}:${admin_password} ${registration_url}
echo "***************"

#curl -u ${admin_username}:${admin_password} --request GET  ${registration_url} --insecure

echo "***************"

curl -u ${admin_username}:${admin_password} --request GET  ${registration_url}/${OIDC_CLIENT_ID} --insecure
