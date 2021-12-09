#!/bin/sh

source env-okta-trial.sh

curl -X POST \
     -H "Accept: application/json" \
     -H "Content-Type:application/json" \
     -d @- "${registration_url}" <<+++
{
    "client_name": "ODM client",
    "application_type": "web",
    "introspect_tokens": true,
    "response_types": ["code", "token", "id_token"],
    "grant_types": ["authorization_code", "client_credentials", "password", "refresh_token", "implicit"],
    "redirect_uris": [
	"https://localhost:9444/oidcclient/redirect/odm",
        "https://localhost:9643/oidcclient/redirect/odm",
	"https://localhost/tokenreceiver"
    ]
}
+++
echo
