#!/bin/bash
#http://localhost:9080/res 
#http://localhost:9080/loan-server/

RESURL="localhost:9080/res"
APIVER="/api/v1/ruleapps"

# This script sets emission properties, including input and output parameters, and trace, for the following rulesets used in the loan-server sample
#  /test_deployment/1.0/loan_validation_with_score_and_grade/1.0
#  /test_deployment/1.0/loan_validation_production/1.0
#  /production_deployment/1.0/loan_validation_production/1.0

# Properties to set
# /properties/bai.emitter.enabled
# /properties/bai.emitter.input
# /properties/bai.emitter.output
# /properties/bai.emitter.trace


# ** Funtion to set property on ruleset, expects ruleset path and property : setProp $1 $2
setProp(){

# set variables from parameters
RULESETPATH=$1
PROPERTY=$2

# build call for main body of curl statement
MYCALL=${RESURL}${APIVER}${RULESETPATH}${PROPERTY}
echo "setting" $MYCALL

response=$(curl --silent --write-out "\n%{http_code}\n" POST -H "Content-Type: text/plain" -k ${MYCALL} -u odmAdmin:odmAdmin -d "true")
status_code=$(echo "$response" | sed -n '$p')
html=$(echo "$response" | sed '$d')
echo "$status_code"

if [ "$status_code" != "200" ]
  then
 #POST was not good: most probably because property already exists, so let's try a DELETE and go again.
 echo "Property may already exist. So, trying to delete and set again..."
 curl -X DELETE ${MYCALL} -u odmAdmin:odmAdmin -d ""
 #try posting again
 a_response=$(curl --silent --write-out "\n%{http_code}\n" POST -H "Content-Type: text/plain" -k $MYCALL -u odmAdmin:odmAdmin -d "true")
   a_status_code=$(echo "$a_response" | sed -n '$p')
   a_html=$(echo "$a_response" | sed '$d')
# echo "$a_status_code"
 if [ "$a_status_code" != "200" ]
   then
    # Trying again did not work ! 
        echo "Unable to set ruleset property " $MYCALL" -- "$a_response" -- please set the emitter properties manually in the res console (https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.dserver.rules.res.console/topics/con_rescons_ruleset_prop.html)"  
 fi
fi
}

# ** End of Function definition setProp

# call setProp for all the properties to set for the loan-server sample
setProp /test_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.enabled
setProp /test_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.input
setProp /test_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.output
setProp /test_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.trace

setProp /test_deployment/1.0/loan_validation_with_score_and_grade/1.0 /properties/bai.emitter.enabled
setProp /test_deployment/1.0/loan_validation_with_score_and_grade/1.0 /properties/bai.emitter.input
setProp /test_deployment/1.0/loan_validation_with_score_and_grade/1.0 /properties/bai.emitter.output
setProp /test_deployment/1.0/loan_validation_with_score_and_grade/1.0 /properties/bai.emitter.trace

setProp /production_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.enabled
setProp /production_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.input
setProp /production_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.output
setProp /production_deployment/1.0/loan_validation_production/1.0 /properties/bai.emitter.trace
