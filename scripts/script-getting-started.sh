#!/bin/bash
#
# Automatically validate and ODM deployment
# Parameters
# * URL of the components : DC, RES , DSR
# * Authentication mechanism : OpenID or BasicAuth
# * Credential: (ClientID/ClientSecret or Username/Password)

#===========================
# Function to run curl request
# - $1 request - ex: POST
# - $2 url "${DC_URL}/decisioncenter-api/v1/decisionservices/import"
# - $3 (Optional) zip file to import - ex: Loan_Validation_Service.zip
function curlRequest {
  if [[ ! -z $3 ]]; then
    curl_result=$(curl --silent --insecure --request $1 $2 --header "accept: application/json" --header "Content-Type: multipart/form-data" --form "file=@$(dirname $0)/$3;type=application/zip" --user ${DC_USER}:${DC_USER})
  else
    curl_result=$(curl --silent --insecure --request $1 $2 --header "accept: application/json" --user ${DC_USER}:${DC_USER})
  fi
  if [[ $? != 0 ]]; then
    echo "Could not connect to $2;  please check that the component is up and running."
    exit 1
  fi
  echo $curl_result
}

#===========================
# Function to import a Decision Service in Decision Center
# - $1 local zip file name
function importDecisionService {
  echo -n "$(date) - ### Upload Loan Validation Service to DC:  "
  curl_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/decisionservices/import $1)
  # echo $curl_result

  status=$(echo ${curl_result} | jq -r '.status')
  if [[ "${status}" == "null" ]]; then
    echo "COMPLETED"
  else
    echo ${status}
  fi
  if [[ "${status}" == "BAD_REQUEST" ]]; then
    echo ${curl_result} | jq -r '.reason'
  fi
  # Set decisionServiceId
  decisionServiceId=$(echo ${curl_result} | jq -r '.decisionService.id')
}

#===========================
# Function to get a Decision Service id in Decision Center
# - $1 Decision Service name
function setDecisionServiceId {
  if [[ "${decisionServiceId}" == "null" ]]; then
    echo -n "$(date) - ### Get Decision Service id to DC:  "
    get_decisionserviceid_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices?q=name%3A$1)
    decisionServiceId=$(echo ${get_decisionserviceid_result} | jq -r '.elements[0].id')
    echo "DONE"
  fi
}

#===========================
# Function to run the Main Scoring Test Suite in Decision Center
# - $1 test suite name
function runTestSuite {
  echo -n "$(date) - ### Run test suite in DC:  "
  # Get Main Scoring test suite id
  get_testSuiteId_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices/${decisionServiceId}/testsuites?q=name%3A$1)
  testSuiteId=$(echo ${get_testSuiteId_result} | jq -r '.elements[0].id')
  # echo ${get_testSuiteId_result}

  # Run Main Scoring test suite
  run_testSuite_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/testsuites/${testSuiteId}/run)
  run_testSuite_status=$(echo ${run_testSuite_result} | jq -r '.status')
  echo $run_testSuite_status

  testReportId=$(echo ${run_testSuite_result} | jq -r '.id')
  # testReportId=c95bcba7-8e35-4572-bae3-95087a646272

  echo -n "$(date) - ### Wait for test suite to be completed in DC:  "
  get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId})
  testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
  while [[ ${testReport_status} != "COMPLETED" ]]; do
    sleep 10
    get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId})
    testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
  done
  echo $testReport_status
  # echo ${get_testReport_result}
  testReports_errors=$(echo ${get_testReport_result} | jq -r '.errors')
  # echo $testReports_errors
  echo -n "$(date) - ### Test report status in DC:  "
  if [[ $testReports_errors != 0 ]]; then
    echo "FAILED"
    exit 1
  else
    echo "SUCCEEDED"
  fi
}

#===========================
# Function to get the deployments Ids in Decision Center
function getDeploymentIds {
  echo -n "$(date) - ### Get elements Ids from DC:  "
  deployments=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices/${decisionServiceId}/deployments)
  # echo $deployments
  if [[ $? != 0 ]]; then
    echo "Could not connect to ${DC_URL};  please check that DC is up and running."
    exit 1
  fi
  echo "DONE"

  deploymentsIds=$(echo ${deployments} | jq -r '.elements | map(.id) | .[]')
}

#===========================
# Function to generate and deploy rulesApp in Decision Center
# - $1 deployment id
function deployRuleApp {
  deploymentId=$1
  ruleapp_name=$(echo ${deployments} | jq -r ".elements[] | select(.id == \"${deploymentId}\").ruleAppName")
  echo -n "$(date) - ### Deploy RuleApp ${ruleapp_name} to DC:  "
  curl_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/deployments/${deploymentId}/deploy)
  # echo $curl_result
  echo $curl_result | jq -r '.status'

}

#===========================
# Function to verify the rulesApp deplyment in RES
# - $1 deployments id
function verifyRuleApp {
  deploymentsId=$1
  ruleapp_name=$(echo ${deployments} | jq -r ".elements[] | select(.id == \"${deploymentId}\").ruleAppName")
  echo -n "$(date) - ### Get RuleApp ${ruleapp_name} in RES:  "
  ruleapps_result=$(curlRequest GET ${RES_URL}/res/api/v1/ruleapps/${ruleapp_name}/1.0)
  # echo $ruleapps_result
  if [[ $? != 0 ]]; then
    echo "Could not connect to ${RES_URL};  please check that DC is up and running."
    exit 1
  fi
  ruleapps_rulesets=$(echo $ruleapps_result | jq -r '.rulesets | map(.name) | .[]')
  echo "DONE"
  echo -n "The RuleApp contains the following rulesets: $ruleapps_rulesets"
}


function main {
  # Scenario:
  # ------------------------------
  # 1. Import the decision service
  # 2. Run Main Scoring test suite
  # 3. Generate and deploying the RuleApp
  # 4. Verify the RuleApp is present in RES
  # 5. Executing the RuleApp in DSR -> TODO

  DC_URL=https://test-odm-dc-route-default.apps.erbium.cp.fyre.ibm.com
  RES_URL=https://test-odm-ds-console-route-default.apps.erbium.cp.fyre.ibm.com/res
  DC_USER=odmAdmin
  decisionServiceId="null"
  deploymentsIds=[]

  importDecisionService Loan_Validation_Service.zip
  if [[ "${decisionServiceId}" == "null" ]]; then
    setDecisionServiceId Loan%20Validation%20Service
  fi

  runTestSuite Main%20Scoring%20test%20suite

  getDeploymentIds
  for deploymentId in ${deploymentsIds[@]}; do
    deployRuleApp $deploymentId
  done

  for deploymentId in ${deploymentsIds[@]}; do
    verifyRuleApp $deploymentId
  done
}
main "$@"
