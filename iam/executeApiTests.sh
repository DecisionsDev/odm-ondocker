#!/bin/sh

# The script invokes ODM APIs using a bearer header (or BA) passed as parameter

# odmhost=https://9.171.58.116:9843
odm_dc_host=https://localhost:9643
odm_dsc_host=https://localhost:9843
odm_dr_host=https://localhost:9743
odm_dsr_host=https://localhost:9943

AUTH="Authorization: Bearer $1"

echo ---------------------------------------------------------------------
echo Invoking: ${odm_dsc_host}/res/api/ruleapps?count=true
echo Response:
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${odm_dsc_host}/res/api/ruleapps?count=true
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odm_dsc_host}/res/auth?ping=pong
echo Response:
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${odm_dsc_host}/res/auth?ping=pong
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odm_dc_host}/decisioncenter-api/v1/about
echo Response:
curl -k \
     -H "$AUTH" \
     ${odm_dc_host}/decisioncenter-api/v1/about 2>&1
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odm_dc_host}/decisioncenter-api/v1/decisionservices
echo Response:
curl -k \
     -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${odm_dc_host}/decisioncenter-api/v1/decisionservices 2>&1
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odm_dr_host}/DecisionRunner/serverinfo
echo Response:
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${odm_dr_host}/DecisionRunner/serverinfo
echo ""

echo ---------------------------------------------------------------------
echo Deploying XOM and the ruleapp...
curl -k -H "Content-Type: application/octet-stream" \
     -H "$AUTH" \
     --data-binary "@/Users/mathiasmouly/testOkta/SampleXOM.zip" \
     ${odm_dsc_host}/res/api/v1/xoms/SampleXOM.zip

curl -k -H "Content-Type: application/octet-stream" \
     -H "$AUTH" \
     --data-binary "@/Users/mathiasmouly/testOkta/ruleApp_DeploySample_1.0.jar" \
     ${odm_dsc_host}/res/api/v1/ruleapps

echo ---------------------------------------------------------------------
echo Invoking: ${odm_dsr_host}/DecisionService/rest/DeploySample/1.0/MainOperation/1.0
echo Response:
curl -k -H "Content-Type: application/json" \
     -H "$AUTH" \
     -d @- "${odm_dsr_host}/DecisionService/rest/DeploySample/1.0/MainOperation/1.0" <<+++
{
  "__DecisionID__": "string",
  "DomainSample": {
    "astr": "string",
    "bstr": "string"
  }
}
+++
echo
