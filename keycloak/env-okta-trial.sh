#!/bin/sh

server_url=http://localhost:8080/auth/realms/master
registration_url=${server_url}/clients-registrations/openid-connect/odm
authorization_url=${server_url}/protocol/openid-connect/auth
token_url=${server_url}/protocol/openid-connect/token
introspect_url=${server_url}/protocol/openid-connect/token/introspect
userinfo_url=${server_url}/protocol/openid-connect/userinfo
revoke_url=${server_url}/protocol/openid-connect/revoke

#api_token=005L3jn9oKFiUZ_jLEyX7S5P2H8t-OM3I8Eyl90Jro
#api_token=00u3x_ODvpkgRlPbe5Vr0o0pT1b2cqqGwnKncUFzbU

username=mathias.mouly@fr.ibm.com
password=Key44me

#***REMOVED***
#***REMOVED***

# Credentials returned by the registration
client_id=odm
client_secret=683a11e8-4dd8-48a5-b97e-81197545e683
#client_id=0oad8hvt6GnerRscC4x6
#client_secret=8X2ex8i-wybsVIX6wGZomTFOLOC-bfzrmQ2q1yYo
