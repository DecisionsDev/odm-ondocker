#!/bin/sh

# The script invokes ODM APIs using a BA or bearer header

# odmhost=https://odm-dev-dbaoc-4qtest2.blueworkscloud.com
# odmhost=https://odm-dev-dbaoc-demo-4q.automationcloud.ibm.com
# odmhost=https://localhost:9444
# odmhost=https://odm-dev-dbaoc-4qtest2.blueworkscloud.com
# odmhost=https://decisioncenter.odm.odmokta.apps.mat-test2.cp.fyre.ibm.com
dc_odmhost=https://9.171.21.112:9643/decisioncenter
dr_odmhost=https://9.171.21.112:9743/DecisionRunner
dsc_odmhost=https://9.171.21.112:9843/res
dsr_odmhost=https://9.171.21.112:9943/DecisionService

# FID Blueworkscloud: cjin-odm.fid@t7916, vzq6lCqwLLV5nZrjYhLN9enplBx4U7xeKci1vJOG
# BA_SAAS_FID="Authorization: Basic Y2ppbi1vZG0uZmlkQHQ3OTE2OnZ6cTZsQ3F3TExWNW5acmpZaExOOWVucGxCeDRVN3hlS2NpMXZKT0c="

# FID automationcloud: cjin.fid@t7918, cgQMKAk4ByXmpNDd30XnLBZbNU5dZTuAGyoU0dLX
#BA_SAAS_FID="Authorization: Basic Y2ppbi5maWRAdDc5MTg6Y2dRTUtBazRCeVhtcE5EZDMwWG5MQlpiTlU1ZFpUdUFHeW9VMGRMWA=="

# FID: cjin.fid@t7916, wxCLYhdY1LpZliCuShO2du6qY7YqJOavB8esCDPm
#BA_SAAS_FID="Authorization: Basic Y2ppbi5maWRAdDc5MTY6d3hDTFloZFkxTHBabGlDdVNoTzJkdTZxWTdZcUpPYXZCOGVzQ0RQbQ=="

# Local host with odmAdmin / odmAdmin
#BA_HEADER="Authorization: Basic b2RtQWRtaW46b2RtQWRtaW4="

#AUTH=$BA_SAAS_FID
# AUTH=$BA_HEADER


AUTH="Authorization: Bearer $1"

echo $AUTH

echo ---------------------------------------------------------------------
echo Invoking: ${odmhost}/res/api/ruleapps?count=true
echo Response:
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${dsc_odmhost}/res/api/ruleapps?count=true
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odmhost}/res/auth?ping=pong
echo Response:
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${dsc_odmhost}/res/auth?ping=pong
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odmhost}/decisioncenter-api/v1/about
echo Response:
curl -k \
     -H "$AUTH" \
     ${dc_odmhost}/decisioncenter-api/v1/about 2>&1
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odmhost}/decisioncenter-api/v1/decisionservices
echo Response:
curl -k \
     -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${dc_odmhost}/decisioncenter-api/v1/decisionservices 2>&1
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odmhost}/decisioncenter-api/v1/servers/ext
echo Response:
curl -k \
     -H "$AUTH" \
     ${dc_odmhost}/decisioncenter-api/v1/servers/ext 2>&1
echo ""

echo ---------------------------------------------------------------------
echo Invoking: ${odmhost}/DecisionRunner/serverinfo
echo Response:
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
     -H "$AUTH" \
     ${dr_odmhost}/DecisionRunner/serverinfo
echo ""

echo ---------------------------------------------------------------------
echo Deploying XOM and the ruleapp...
curl -k -H "Content-Type: application/octet-stream" \
     -H "$AUTH" \
     --data-binary "@./rulesets/SampleXOM.zip" \
     ${dsc_odmhost}/res/api/v1/xoms/SampleXOM.zip

curl -k -H "Content-Type: application/octet-stream" \
     -H "$AUTH" \
     --data-binary "@./rulesets/ruleApp_DeploySample_1.0.jar" \
     ${dsc_odmhost}/res/api/v1/ruleapps

echo ---------------------------------------------------------------------
echo Invoking: ${dsr_odmhost}/DecisionService/rest/DeploySample/1.0/MainOperation/1.1
echo Response:
curl -k -H "Content-Type: application/json" \
     -H "$AUTH" \
     -d @- "${dsr_odmhost}/DecisionService/rest/DeploySample/1.0/MainOperation/1.1" <<+++
{
  "__DecisionID__": "string",
  "DomainSample": {
    "astr": "string",
    "bstr": "string"
  }
}
+++
echo
