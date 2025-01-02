#!/bin/bash

if [ -n "$USERS_PASSWORD" ]
then
	echo "Update servers password on sample database"
	SERVERS=$(curl -s --location --request GET 'http://localhost:9060/decisioncenter-api/v1/servers' -H "Content-Type: application/json;charset=UTF-8" -u odmAdmin:$USERS_PASSWORD)
	SERVERS_ID=$(echo "$SERVERS" | jq -r '.elements[] | .id')

	for server_id in $SERVERS_ID; do
        	curl -s --location --request POST "http://localhost:9060/decisioncenter-api/v1/servers/$server_id" -H "Content-Type: application/json;charset=UTF-8" -u odmAdmin:$USERS_PASSWORD -d "{ \"loginPassword\": \"$USERS_PASSWORD\" }"
	done
fi
