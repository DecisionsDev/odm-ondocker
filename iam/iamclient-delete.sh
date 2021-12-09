#!/bin/sh

***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

#curl -k -s -X GET -u ${admin_username}:${admin_password} ${registration_url}
echo "***************"

#curl -u ${admin_username}:${admin_password} --request GET  ${registration_url} --insecure

echo "***************"

curl -u ${admin_username}:${admin_password} --request DELETE  ${registration_url}/${OIDC_CLIENT_ID} --insecure
