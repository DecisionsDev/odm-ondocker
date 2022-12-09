#!/bin/bash
#
# Automatically validate and ODM deployment
# Parameters
# * URL of the components : DC, RES , DSR
# * Authentication mechanism : OpenID or BasicAuth
# * Credential: (ClientID/ClientSecret or Username/Password)

function print_usage {
  me=`basename "$0"`
  cat <<EOF

Usage: $me -c <DC_URL> -r <RES_URL> [-h]

The script validates an ODM deployment.

Required options:
    -c  # URL of the Decision Center instance to test.
    -r  # URl of the Decision Server Console (RES) instance to test.

Optional:
    -h  # Displays this help page

Example:
    ${me} -c https://<DC_ROUTE> -r https://<RES_ROUTE>

EOF
  exit 0
}

function parse_args {
  while getopts "h?c:r:" opt; do
    case "$opt" in
    h|\?)
      print_usage
      exit 0
      ;;
    c)  DC_URL=$OPTARG
      ;;
    r)  RES_URL=$OPTARG
      ;;
    :)  echo "Invalid option: -$OPTARG requires an argument"
      print_usage
      exit -1
      ;;
    esac
  done
  if [ -z $DC_URL ]; then
    echo "Option -c is required"
    print_usage
    exit -1
  fi

  if [ -z $RES_URL ]; then
    echo "Option -r is required"
    print_usage
    exit -1
  fi
}

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
  echo -n "$(date) - ### Upload Decision Service to DC:  "
  curl_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/decisionservices/import $1)

  # Check status
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

  # Run Main Scoring test suite
  run_testSuite_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/testsuites/${testSuiteId}/run)
  run_testSuite_status=$(echo ${run_testSuite_result} | jq -r '.status')
  echo $run_testSuite_status
  testReportId=$(echo ${run_testSuite_result} | jq -r '.id')

  echo -n "$(date) - ### Wait for test suite to be completed in DC:  "
  get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId})
  testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
  while [[ ${testReport_status} != "COMPLETED" ]]; do
    sleep 10
    get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId})
    testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
  done
  echo $testReport_status

  # Check for errors
  testReports_errors=$(echo ${get_testReport_result} | jq -r '.errors')
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
  echo -n "$(date) - ### Get deployments Ids from DC:  "
  deployments=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices/${decisionServiceId}/deployments)
  echo "DONE"
  # Set deployment ids
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

  ruleapps_rulesets=$(echo $ruleapps_result | jq -r '.rulesets | map(.name) | .[]')
  echo "DONE"
  echo "The RuleApp contains the following rulesets:"
  echo $ruleapps_rulesets
}

#===========================
# Function to test Loan Validation in RES
function testLoanValidation {
  echo -n "$(date) - ### Test Loan Validation in RES:  "
  curl_result=$(curl --silent --insecure --request POST ${RES_URL}/DecisionService/rest/production_deployment/1.0/loan_validation_production/1.0 --header "accept: application/json" --header "Content-Type: application/json" -d "@$(dirname $0)/test.json" --user ${DC_USER}:${DC_USER})

  error_message=$(echo ${curl_result} | jq -r '.message')
  if [[ "${error_message}" == "null" ]]; then
    echo "COMPLETED"
  else
    echo "ERROR"
    echo ${curl_result} | jq -r '.details'
  fi
}

function main {
  # Scenario:
  # ------------------------------
  # 1. Import the decision service
  # 2. Run Main Scoring test suite
  # 3. Generate and deploying the RuleApp
  # 4. Verify the RuleApp is present in RES
  # 5. Executing the RuleApp in DSR

  DC_USER=odmAdmin
  decisionServiceId="null"
  deploymentsIds=[]

  parse_args "$@"

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

  testLoanValidation

}
main "$@"
