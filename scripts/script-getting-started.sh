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

Usage: $me -c <DC_URL> -r <RES_URL> -s <DSR_URL> [-h]

The script validates an ODM deployment.

Required options:
    -c  # URL of the Decision Center instance to test.
    -r  # URl of the Decision Server Console (RES) instance to test.
    -s  # URl of the Decision Server Runtime instance to test.

Optional:
    -h  # Displays this help page

Example:
    ${me} -c https://<DC_ROUTE> -r https://<RES_ROUTE> -s https://<DSR_ROUTE>

EOF
  exit 0
}

function parse_args {
  while getopts "h?c:r:s:" opt; do
    case "$opt" in
    h|\?)
      print_usage
      exit 0
      ;;
    c)  DC_URL=${OPTARG%/}
      ;;
    r)  RES_URL=${OPTARG%/}
      ;;
    s)  DSR_URL=${OPTARG%/}
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
# Function to set authentication arguments for curl request

# ODM_CREDS is defined
# openIdUrl is optionally defined

function setAuthentication {
  # Define authentication
  if [[ ! -z $openIdUrl ]]; then
    clientId="${ODM_CREDS%:*}"
    clientSecret="${ODM_CREDS##*:}"

    # Get bearer token
    get_token_result=$(curl --silent -k -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=${clientId}&scope=openid&client_secret=${clientSecret}&grant_type=client_credentials" "${openIdUrl}/protocol/openid-connect/token")
    access_token=$(echo ${get_token_result} | jq -r '.access_token')

    authArgs+=(-H "Authorization: Bearer ${access_token}")
  else
    authArgs+=(--user ${ODM_CREDS})
  fi
}

#===========================
# Function to run curl request
# - $1 request - ex: POST
# - $2 url "${DC_URL}/decisioncenter-api/v1/decisionservices/import"
# - $3 (Optional) zip or json file to import - ex: Loan_Validation_Service.zip
function curlRequest {
  extraArgs=()
  if [[ ! -z $3 ]]; then
    filename=$3
    extension="${filename##*.}"
    case "$extension" in
    zip)
      extraArgs+=(--header "Content-Type: multipart/form-data" --form "file=@$(dirname $0)/${filename};type=application/zip")
      ;;
    json)
      extraArgs+=(--header "Content-Type: application/json" -d "@$(dirname $0)/${filename}")
      ;;
    :)
      echo "Invalid file type: only json and zip are supported"
      exit -1
      ;;
    esac
  fi

  curl_result=$(curl --silent --insecure -w "|%{http_code}" --request $1 $2 --header "accept: application/json" "${extraArgs[@]}" "${authArgs[@]}")
  
  # Handle curl errors
  exit_code=$?
  if [[ $exit_code != 0 ]]; then
    echo "Could not connect to $2; please check that the component is up and running at this url."
    exit 1
  fi

  # Handle http errors
  http_code="${curl_result##*|}"
  body="${curl_result%|*}"
  echo $body
  if [[ $http_code -ne 200 ]]; then
    exit $http_code
  fi
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
    decision_service_name=$1
    echo -n "$(date) - ### Get ${decision_service_name} id to DC:  "
    get_decisionserviceid_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices?q=name%3A${decision_service_name// /%20})
    decisionServiceId=$(echo ${get_decisionserviceid_result} | jq -r '.elements[0].id')
    echo "DONE"
  fi
}

#===========================
# Function to run the Main Scoring Test Suite in Decision Center
# - $1 test suite name
function runTestSuite {
  test_suite_name=$1
  echo -n "$(date) - ### Run ${test_suite_name} in DC:  "
  # Get Main Scoring test suite id
  get_testSuiteId_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices/${decisionServiceId}/testsuites?q=name%3A${test_suite_name// /%20})
  testSuiteId=$(echo ${get_testSuiteId_result} | jq -r '.elements[0].id')

  # Run Main Scoring test suite
  run_testSuite_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/testsuites/${testSuiteId}/run)
  run_testSuite_status=$(echo ${run_testSuite_result} | jq -r '.status')
  echo $run_testSuite_status
  testReportId=$(echo ${run_testSuite_result} | jq -r '.id')

  echo -n "$(date) - ### Wait for ${test_suite_name} to be completed in DC:  "
  get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId})
  testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
  while [[ ${testReport_status} == "STARTING" ]]; do
    sleep 2
    get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId})
    testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
  done
  echo "DONE"

  # Check for errors
  testReports_errors=$(echo ${get_testReport_result} | jq -r '.errors')
  echo -n "$(date) - ### Test report status in DC:  "
  if [[ $testReports_errors != 0 ]] || [[ ${testReport_status} == "FAILED" ]]; then
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
  error_message=$(echo ${deployments} | jq -r '.error')
  if [[ "${error_message}" == "null" ]]; then
    echo "DONE"
  else
    echo "ERROR"
    echo ${deployments} | jq -r '.reason'
    exit 1
  fi
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
# Function to test a RuleSet in DSR
# - $1 path of the RuleSet to test
# - $2 json file in local directory
# - $3 response file
function testRuleSet {
  echo -n "$(date) - ### Test RuleSet $1 in DSR:  "
  curl_result=$(curlRequest POST ${DSR_URL}/DecisionService/rest/$1 $2)

  error_message=$(echo ${curl_result} | jq -r '.message')
  if [[ "${error_message}" == "null" ]]; then
    echo "COMPLETED"
  else
    echo "ERROR"
    echo ${curl_result} | jq -r '.details'
  fi

  echo -n "$(date) - ### Check RuleSet test result in DSR:  "
  diff=$(diff <(echo ${curl_result} | jq -S .) <(jq -S . $3))
  if [[ "${diff}" == "" ]]; then
    echo "SUCCEDED"
  else
    echo "FAILED"
    echo ${diff}
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

  # Need to set ODM_CREDS and openIdUrl
  decisionServiceId="null"
  deploymentsIds=[]
  authArgs=()

  parse_args "$@"

  setAuthentication

  importDecisionService Loan_Validation_Service.zip
  if [[ "${decisionServiceId}" == "null" ]]; then
    setDecisionServiceId "Loan Validation Service"
  fi

  runTestSuite "Main Scoring test suite"

  getDeploymentIds
  for deploymentId in ${deploymentsIds[@]}; do
    deployRuleApp $deploymentId
  done

  for deploymentId in ${deploymentsIds[@]}; do
    verifyRuleApp $deploymentId
  done

  testRuleSet production_deployment/1.0/loan_validation_production/1.0 loan_validation_test.json loan_validation_test_response.json

}
main "$@"
