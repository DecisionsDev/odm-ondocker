#!/bin/sh

export admin_username=<oauthAdmin_login>
export admin_password=<oauthAdmin_password>
export registration_url=https://cp-console.apps.<fyre_master_ip>.nip.io/idauth/oidc/endpoint/OP/registration
export client_name=<ODM_OIDC_CLIENT_ID>
export client_secret=ODM_OIDC_CLIENT_SECRET>
export client_id=<ODM_OIDC_CLIENT_ID>

# Note: the functional_user_id and functional_user_groupIds are the functional user
# and groups for client_crendetials. This works from 19.0.0.4.

curl -k -s -X PUT \
     -H "Content-Type:application/json" \
     -u "${admin_username}:${admin_password}" \
     -d @- "${registration_url}/${client_name}" <<+++
{
 "client_id": "${client_id}",
 "client_secret": "${client_secret}",
 "token_endpoint_auth_method":"client_secret_basic",
 "scope":"openid profile email",  
 "grant_types":[
      "authorization_code",
      "client_credentials",
      "implicit",
      "refresh_token",
      "urn:ietf:params:oauth:grant-type:jwt-bearer",
      "password"
 ],
 "response_types":["code","token","id_token"],
 "application_type":"web",
 "subject_type":"public",
 "preauthorized_scope": "openid profile email",
 "introspect_tokens":true,
 "allow_regexp_redirects":true,
 "appPasswordAllowed":true,
 "appTokenAllowed":true,
 "hash_itr":0,
 "hash_len":0,
 "preauthorized_scope": "openid",
 "introspect_tokens": true,
 "redirect_uris": ["https://localhost:9643/odm/decisioncenter/openid/redirect/odm","https://localhost:9643/decisioncenter/openid/redirect/odm","https://localhost:9743/DecisionRunner/openid/redirect/odm","https://localhost:9843/res/openid/redirect/odm","https://localhost:9943/DecisionService/openid/redirect/odm","https://cpd-odm.apps.9.20.212.178.nip.io/odm/decisioncenter/openid/redirect/odm","https://cpd-odm.apps.9.20.212.178.nip.io/odm/res/openid/redirect/odm","https://cpd-odm.apps.9.20.212.178.nip.io/odm/DecisionRunner/openid/redirect/odm","https://cpd-odm.apps.9.20.212.178.nip.io/odm/DecisionService/openid/redirect/odm","http://127.0.0.1:9081/oidcCallback","http://127.0.0.1:19081/oidcCallback","http://127.0.0.1:29081/oidcCallback","http://127.0.0.1:39081/oidcCallback","https://localhost/tokenreceiver"]
}
+++
echo
