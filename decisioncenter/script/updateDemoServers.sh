#!/bin/bash

sleep 60

PROTOCOL=http

if [ -n "$ENABLE_TLS" ]
then
	PROTOCOL=https
fi

DSC_HOST=odm-decisionserverconsole

if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
	DSC_HOST=$DECISIONSERVERCONSOLE_NAME
fi

DR_HOST=odm-decisionrunner

if [ -n "$DECISIONRUNNER_NAME" ]
then
	DR_HOST=$DECISIONRUNNER_NAME
fi

DSC_PORT=9080

if [ -n "$DECISIONSERVERCONSOLE_PORT" ]
then
	DSC_PORT=$DECISIONSERVERCONSOLE_PORT
fi

DR_PORT=9080

if [ -n "$DECISIONRUNNER_PORT" ]
then
	DR_PORT=$DECISIONRUNNER_PORT
fi

if [ -n "$ODM_CONTEXT_ROOT" ]
then
DSE_URL=$PROTOCOL"://"$DSC_HOST":"$DSC_PORT""$ODM_CONTEXT_ROOT"/res"
DR_URL=$PROTOCOL"://"$DR_HOST":"$DR_PORT""$ODM_CONTEXT_ROOT"/DecisionRunner"
CURL_URL=http://localhost:9060$ODM_CONTEXT_ROOT
else
DSE_URL=$PROTOCOL"://"$DSC_HOST":"$DSC_PORT"/res"
DR_URL=$PROTOCOL"://"$DR_HOST":"$DR_PORT"/DecisionRunner"
CURL_URL=http://localhost:9060
fi

ZEN_ENABLED=$(grep ZenApiKey /config/auth/OdmOidcProviders.json)
echo "ZEN_ENABLED= $ZEN_ENABLED"

if [[ -n $OPENID_CONFIG && -z $ZEN_ENABLED ]]
then

OPENID_PROVIDER=$(grep OPENID_PROVIDER /config/authOidc/openIdParameters.properties | sed "s/OPENID_PROVIDER=//g")
echo "will update Decision Service Execution with $DSE_URL in OAUTH mode with provider $OPENID_PROVIDER"

retry=0
while [[ ("$(curl -X POST "$CURL_URL/decisioncenter-api/v1/servers/62293377-13e9-457f-b756-7710357ca1ab" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"url\": \"$DSE_URL\",\"authenticationKind\": \"OAUTH\",\"authenticationProvider\": \"$OPENID_PROVIDER\" }" -H "authorization: Basic b2RtQWRtaW46b2RtQWRtaW4=" -w "%{http_code}" -s -o /dev/null)" != 200) && ( $retry -lt 10) ]];do 
	echo "retry updating Decision Service Execution with $DSE_URL in OAUTH mode with provider $OPENID_PROVIDER"
	sleep 5
	retry=$((retry + 1))
done

if [[ $retry == 10 ]];then
	echo "failed to update Decision Service Execution with $DSE_URL"
else
	echo "successfully updated Decision Service Execution with $DSE_URL"
fi
echo "will update Test and Simulation Execution with $DR_URL in OAUTH mode with provider $OPENID_PROVIDER"
retry=0
while [[ ("$(curl -X POST "$CURL_URL/decisioncenter-api/v1/servers/f4f01813-1ec1-4c89-b773-3d9e2afafab1" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"url\": \"$DR_URL\",\"authenticationKind\": \"OAUTH\",\"authenticationProvider\": \"$OPENID_PROVIDER\" }" -H "authorization: Basic b2RtQWRtaW46b2RtQWRtaW4=" -w "%{http_code}" -s -o /dev/null)" != 200)  && ( $retry -lt 10) ]];do
        echo "retry updating Test and Simulation Execution with $DR_URL in OAUTH mode with provider $OPENID_PROVIDER"
        sleep 5
	retry=$((retry + 1))
done

if [[ $retry == 10 ]];then
        echo "failed to update Test and Simulation Execution with $DR_URL"
else
	echo "successfully updated Test and Simulation Execution with $DR_URL"
fi

else
echo "will update Decision Service Execution with $DSE_URL"
retry=0
while [[ ("$(curl -X POST "$CURL_URL/decisioncenter-api/v1/servers/62293377-13e9-457f-b756-7710357ca1ab" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"url\": \"$DSE_URL\" }" -H "authorization: Basic b2RtQWRtaW46b2RtQWRtaW4=" -w "%{http_code}" -s -o /dev/null)" != 200) && ( $retry -lt 10) ]];do
        echo "retry updating Decision Service Execution with $DSE_URL"
        sleep 5
        retry=$((retry + 1))
done

if [[ $retry == 10 ]];then
        echo "failed to update Decision Service Execution with $DSE_URL"
else
        echo "successfully updated Decision Service Execution with $DSE_URL"
fi

echo "will update Test and Simulation Execution with $DR_URL"
retry=0
while [[ ("$(curl -X POST "$CURL_URL/decisioncenter-api/v1/servers/f4f01813-1ec1-4c89-b773-3d9e2afafab1" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"url\": \"$DR_URL\" }" -H "authorization: Basic b2RtQWRtaW46b2RtQWRtaW4=" -w "%{http_code}" -s -o /dev/null)" != 200)  && ( $retry -lt 10) ]];do
        echo "try updating Test and Simulation Execution with $DR_URL"
        sleep 5
        retry=$((retry + 1))
done

if [[ $retry == 10 ]];then
        echo "failed to update Test and Simulation Execution with $DR_URL"
else
        echo "successfully updated Test and Simulation Execution with $DR_URL"
fi

fi
