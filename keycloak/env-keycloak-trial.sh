#!/bin/bash

server_url=http://keycloak-keycloak.apps.kanab.cp.fyre.ibm.com/auth/realms/master
authorization_url=${server_url}/protocol/openid-connect/auth
token_url=${server_url}/protocol/openid-connect/token
introspect_url=${server_url}/protocol/openid-connect/token/introspect


username=jdoe
password=jdoe

#username=admin
#password=admin

# Credentials returned by the registration
client_id=odm
client_secret=vU8bLJ9iumYjEvr0EmqsHQLmoFSqoU4F
