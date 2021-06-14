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

DSE_URL=$PROTOCOL"://"$DSC_HOST":"$DSC_PORT"/res"

DR_URL=$PROTOCOL"://"$DR_HOST":"$DR_PORT"/DecisionRunner"

retry=0
while [[ ("$(curl -X POST "http://localhost:9060/decisioncenter-api/v1/servers/d8cb5830-14aa-45e0-89e2-8837f4d91021" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"url\": \"$DSE_URL\"}" -H "authorization: Basic b2RtQWRtaW46b2RtQWRtaW4=" -w "%{http_code}" -s -o /dev/null)" != 200) && ( $retry -lt 10) ]];do 
	echo "try updating Decision Service Execution with $DSE_URL"
	sleep 5
	retry=$((retry + 1))
done

if [[ $retry == 10 ]];then
	echo "failed to update Decision Service Execution with $DSE_URL"
else
	echo "successfully updated Decision Service Execution with $DSE_URL"
fi

retry=0
while [[ ("$(curl -X POST "http://localhost:9060/decisioncenter-api/v1/servers/a677f1c1-8633-42ff-8e4e-994fb52b3384" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"url\": \"$DR_URL\"}" -H "authorization: Basic b2RtQWRtaW46b2RtQWRtaW4=" -w "%{http_code}" -s -o /dev/null)" != 200)  && ( $retry -lt 10) ]];do
        echo "try updating Test and Simulation Execution with $DR_URL"
        sleep 5
	retry=$((retry + 1))
done

if [[ $retry == 10 ]];then
        echo "failed to update Test and Simulation Execution with $DR_URL"
else
	echo "successfully updated Test and Simulation Execution with $DR_URL"
fi
