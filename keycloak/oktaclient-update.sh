#!/bin/sh

source env-okta-trial.sh

curl -X PUT \
     -H "Accept: application/json" \
     -H "Content-Type:application/json" \
     -H "Authorization: SSWS ${api_token}" \
     -d @- "${registration_url}/${client_id}" <<+++
{
    "client_id": "${client_id}",
    "client_name": "ODM client",
    "client_uri": "https://www.example-application.com",
    "application_type": "web",
    "response_types": ["code", "token", "id_token"],
    "grant_types": ["authorization_code", "refresh_token", "implicit"],
    "token_endpoint_auth_method": "client_secret_post",
    "redirect_uris": [
	"https://localhost/tokenreceiver",
	"https://localhost/tokenreceiver2",
        "https://localhost:9444/oidcclient/redirect/odm",
        "https://localhost:9643/oidcclient/redirect/odm",
	"https://localhost:9743/oidcclient/redirect/odm",
	"https://localhost:9843/oidcclient/redirect/odm",
	"https://localhost:9943/oidcclient/redirect/odm",
        "https://9.171.58.116:9643/oidcclient/redirect/odm",
        "https://9.171.58.116:9743/oidcclient/redirect/odm",
        "https://9.171.58.116:9843/oidcclient/redirect/odm",
        "https://9.171.58.116:9943/oidcclient/redirect/odm"
    ]
}
+++
echo
