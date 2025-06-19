#!/bin/bash

if [ -n "$USERS_PASSWORD" ]
then
if [[ "$USERS_PASSWORD" != odmAdmin ]]
then
	echo "Update servers password on sample database"
	SERVERS=$(curl -s --location --request GET 'http://localhost:9060/decisioncenter-api/v1/servers' -H "Content-Type: application/json;charset=UTF-8" -u odmAdmin:$USERS_PASSWORD -w "%{http_code}" -s -o /dev/null)
	retry=0
	while [[ ("$SERVERS" != 200) && ( $retry -lt 10) ]];do 
		echo "Get Servers retry : $retry"
		sleep 10
		retry=$((retry + 1))
        	SERVERS=$(curl -s --location --request GET 'http://localhost:9060/decisioncenter-api/v1/servers' -H "Content-Type: application/json;charset=UTF-8" -u odmAdmin:$USERS_PASSWORD -w "%{http_code}" -s -o /dev/null)
	done

	SERVERS=$(curl -s --location --request GET 'http://localhost:9060/decisioncenter-api/v1/servers' -H "Content-Type: application/json;charset=UTF-8" -u odmAdmin:$USERS_PASSWORD)

	SERVERS_ID=$(echo "$SERVERS" | jq -r '.elements[] | .id')
	echo "Server ID : $SERVERS_ID"

	for server_id in $SERVERS_ID; do
        	curl -s --location --request POST "http://localhost:9060/decisioncenter-api/v1/servers/$server_id" -H "Content-Type: application/json;charset=UTF-8" -u odmAdmin:$USERS_PASSWORD -d "{ \"loginPassword\": \"$USERS_PASSWORD\" }"
	done
else
	echo "No update as odmAdmin password is the original one"
fi
fi
