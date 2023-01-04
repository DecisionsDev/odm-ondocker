#!/bin/bash

# Constants
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

function print_usage {
  me=`basename "$0"`
  cat <<EOF

Usage: $me [-c] [-h]

The script validates an ODM deployment.

You have to define the following environment variables manually or in a .env file:
  - DC_URL      # URL of the Decision Center instance to test.
  - RES_URL     # URl of the Decision Server Console (RES) instance to test.
  - DSR_URL     # URl of the Decision Server Runtime instance to test.
  - ODM_CREDS   # Credentials to connect to ODM
                - in basic authentication mode use the format 'user:password'
                - in openID authentication mode, use the format 'clientId:clientSecret'
  - OPENID_URL  # [Optional] URL of the OpenId Server, required in openID authentication mode

Optional script parameters:
    -c  # Cleans the created ruleApps at the end of the test
    -h  # Displays this help page

Example:
    ${me} -c

EOF
}

function parse_args {
  # Set environment variables
  set -a
  [[ -f ".env" ]] && source .env
  set +a

  # Check required environment variables
  if [ -z $DC_URL ]; then
    print_usage
    error "DC_URL environment variable should be defined. Please export it manually or set it in a .env file."
  fi
  if [ -z $RES_URL ]; then
    print_usage
    error "RES_URL environment variable should be defined"
  fi
  if [ -z $DSR_URL ]; then
    print_usage
    error "DSR_URL environment variable should be defined"
  fi
  if [ -z $ODM_CREDS ]; then
    print_usage
    error "ODM_CREDS environment variable should be defined"
  fi

  while getopts "h?f:c" opt; do
    case "$opt" in
    h|\?)
      print_usage
      exit 0
      ;;
    c)  CLEAN=true
      ;;
    :)  echo "Invalid option: -${OPTARG} requires an argument"
      print_usage
      exit -1
      ;;
    esac
  done

}

#===========================
# Function to echo error message and exit script
# - $1 error title
# - $2 error message
# - $3 return code - default value is 1

function error {
  echo -e "${RED}$1${NC}"
  echo -e "${RED}$2${NC}"
  exit "${3:-1}"
}

#===========================
# Function to echo success message
# - $1 message

function echo_success {
  echo -e "${GREEN}$1${NC}"
}

#===========================
# Function to set authentication arguments for curl request

# ODM_CREDS is defined
# OPENID_URL is optionally defined

function setAuthentication {
  # Define authentication
  if [[ ! -z $OPENID_URL ]]; then
    clientId="${ODM_CREDS%:*}"
    clientSecret="${ODM_CREDS##*:}"

    # Get bearer token
    get_token_result=$(curl --silent -k -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=${clientId}&scope=openid&client_secret=${clientSecret}&grant_type=client_credentials" "${OPENID_URL}/protocol/openid-connect/token")
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
  echo -n "📥  Upload Decision Service to DC:  "
  curl_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/decisionservices/import $1)

  # Check status
  status=$(echo ${curl_result} | jq -r '.status')
  case "${status}" in
  "null")
    echo_success "COMPLETED"
    ;;
  "BAD_REQUEST")
    echo ${status}
    echo ${curl_result} | jq -r '.reason'
    ;;
  *)
    error "${status}" "$(echo ${curl_result} | jq -r '.reason')"
    ;;
  esac
}

#===========================
# Function to get a Decision Service id in Decision Center
# - $1 Decision Service name
function getDecisionServiceId {
  decision_service_name=$1
  get_decisionserviceid_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices?q=name%3A${decision_service_name// /%20}) || error "${get_decisionserviceid_result}" "" 1

  decisionServiceId=$(echo ${get_decisionserviceid_result} | jq -r '.elements[0].id')
  [[ "${decisionServiceId}" == "null" ]] && error "Decision Service ${decision_service_name} not found" "" 1
  echo ${decisionServiceId}
}

#===========================
# Function to run the Main Scoring Test Suite in Decision Center
# - $1 Decision Service id
# - $2 test suite name
function runTestSuite {
  decisionServiceId=$1
  test_suite_name=$2
  echo "🧪   Running ${test_suite_name} in DC ...  "
  # Get Main Scoring test suite id
  get_testSuiteId_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices/${decisionServiceId}/testsuites?q=name%3A${test_suite_name// /%20}) || error "ERROR" "${get_testSuiteId_result}" $?
  testSuiteId=$(echo ${get_testSuiteId_result} | jq -r '.elements[0].id')

  # Run Main Scoring test suite
  run_testSuite_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/testsuites/${testSuiteId}/run) || error "ERROR $?" "${run_testSuite_result}" $?
  testReportId=$(echo ${run_testSuite_result} | jq -r '.id')

  echo -n "    ▪ Wait for ${test_suite_name} to be completed in DC:  "
  get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId}) || error "ERROR $?" "${get_testReport_result}" $?
  testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
  i=0
  while [[ ${testReport_status} == "STARTING" ]] && [[ $i -lt 10 ]]; do
    sleep 2
    get_testReport_result=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/testreports/${testReportId}) || error "ERROR $?" "${get_testReport_result}" $?
    testReport_status=$(echo ${get_testReport_result} | jq -r '.status')
    i+=1
  done
  [[ $i -lt 10 ]] && echo_success "DONE" || error "ERROR" "Test is still staring after 20s"

  # Check for errors
  testReports_errors=$(echo ${get_testReport_result} | jq -r '.errors')
  echo -n "    ▪ Test report status in DC:  "
  if [[ $testReports_errors != 0 ]] || [[ ${testReport_status} == "FAILED" ]]; then
    error "FAILED" "The test failed or has errors please check the report created." 1
  else
    echo_success "SUCCEEDED"
  fi
}

#===========================
# Function to get the deployments information in Decision Center
# - $1 Decision Service id
function getDeploymentInfo {
  decisionServiceId=$1
  deployments=$(curlRequest GET ${DC_URL}/decisioncenter-api/v1/decisionservices/${decisionServiceId}/deployments) || error "${deployments}" "" $?

  # Set deployment information
  deploymentsInfo=$(echo -n ${deployments} | jq -c '[.elements[] | {id: .id, ruleAppName: .ruleAppName, ruleAppVersion: .ruleAppVersion}]')
  [[ ! -z "${deploymentsInfo}" ]] && echo ${deploymentsInfo} || error "No deployment found in the given decision service" ""
}

#===========================
# Function to generate and deploy ruleApp in Decision Center
# - $1 deployment id
# - $2 ruleApp name
# - $3 ruleApp version
function deployRuleApp {
  deploymentId=$1
  ruleapp_name=$2
  ruleapp_version=$3
  echo -n "🚀  Deploy RuleApp ${ruleapp_name}/${ruleapp_version} to DC:  "
  curl_result=$(curlRequest POST ${DC_URL}/decisioncenter-api/v1/deployments/${deploymentId}/deploy) || error "ERROR $?" "${curl_result}" $?

  # Set deployment creation timestamp
  deployment_date=$(echo $curl_result | jq -r '.name' | cut -d' ' -f2-) # Report 2023-01-03_11-28-39-945
  date="${deployment_date%_*}"
  time="${deployment_date##*_}"
  formated_time=$(echo ${time%-*}.${time##*-} | tr - :)
  deployment_timestamp=$(date -d "${date}T${formated_time}Z" +%s)

  deployment_status=$(echo $curl_result | jq -r '.status')
  [[ "${deployment_status}" == "COMPLETED" ]] && echo_success "${deployment_status}" || error "ERROR" "The status of ${ruleapp_name} is: ${deployment_status}" 1
}

#===========================
# Function to verify the ruleSet deployed in RES
# - $1 ruleApp name
# - $2 ruleApp version
# - $3 ruleSet name
function verifyRuleSet {
  ruleapp_name=$1
  ruleapp_version=$2
  ruleset_name=$3
  rulesets_result=$(curlRequest GET ${RES_URL}/res/api/v1/ruleapps/${ruleapp_name}/${ruleapp_version}/${ruleset_name}) || error "ERROR $?" "${rulesets_result}" $?

  # Get the last ruleSet version
  read ruleset_version creation_date < <(echo "${rulesets_result}" | jq -r 'sort_by(.version | split(".") | map(tonumber)) | .[-1] | .version + " " + .creationDate')
  echo -n "    ▪ Verify last RuleSet deployed ${ruleapp_name}/${ruleapp_version}/${ruleset_name}/${ruleset_version} in RES:  "

  creation_timestamp=$(date -d ${creation_date} +%s)
  [[ $creation_timestamp -ge $deployment_timestamp ]] && echo_success "SUCCEEDED" || error "ERROR" "The last deployed ruleSet version has been created before the deployment" 1
}

#===========================
# Function to verify the ruleApp deployment in RES
# - $1 ruleApp name
# - $2 ruleApp version
function verifyRuleApp {
  ruleapp_name=$1
  ruleapp_version=$2
  echo "🔎  Verifying test_deployment RuleApp deployment ..."
  echo -n "    ▪ Get RuleApp ${ruleapp_name}/${ruleapp_version} in RES:  "
  ruleapps_result=$(curlRequest GET ${RES_URL}/res/api/v1/ruleapps/${ruleapp_name}/${ruleapp_version}) || error "ERROR $?" "${ruleapps_result}" $?

  ruleapps_rulesets=$(echo $ruleapps_result | jq -r '.rulesets | map(.name) | unique | .[]')
  echo_success "DONE"
  for ruleset_name in ${ruleapps_rulesets[@]}; do
    verifyRuleSet $ruleapp_name $ruleapp_version $ruleset_name
  done
}

#===========================
# Function to test a RuleSet in DSR
# - $1 path of the RuleSet to test
# - $2 json file in local directory
# - $3 response file
function testRuleSet {
  echo "🧪   Running RuleSet test ..."
  echo -n "    ▪ Test RuleSet $1 in DSR:  "
  curl_result=$(curlRequest POST ${DSR_URL}/DecisionService/rest/$1 $2) || error "ERROR $?" "${curl_result}" $?

  error_message=$(echo ${curl_result} | jq -r '.message')
  [[ "${error_message}" == "null" ]] && echo_success "COMPLETED" || echo "ERROR" "$(echo ${curl_result} | jq -r '.details')" 1

  echo -n "    ▪ Check RuleSet test result in DSR:  "
  diff=$(diff <(echo ${curl_result} | jq -S .) <(jq -S . $3))
  [[ "${diff}" == "" ]] && echo_success "SUCCEEDED" || error "FAILED" "There are differencies with the expected response :\n${diff}" 1
}

#===========================
# Function to delete a ruleApp deployment in RES
# - $1 ruleApp name
# - $2 ruleApp version
function deleteRuleApp {
  ruleapp_name=$1
  ruleapp_version=$2
  echo -n "    ▪ Delete RuleApp ${ruleapp_name}/${ruleapp_version} in RES:  "
  ruleapps_result=$(curlRequest DELETE ${RES_URL}/res/api/v1/ruleapps/${ruleapp_name}/${ruleapp_version}) || error "ERROR $?" "${ruleapps_result}" $?

  echo_success "DONE"
}

#===========================
# Function to clean after test
# - $1 deployment information
function clean {
  if [[ ${CLEAN} ]]; then
    echo "🗑️   Cleaning ..."
    deploymentsList=$1
    # Clean ruleApps in RES
    echo "${deploymentsList}" | jq -r '.[] | .id + " " + .ruleAppName + " " + .ruleAppVersion' | while read deploymentId ruleAppName ruleAppVersion; do
      deleteRuleApp ${ruleAppName} ${ruleAppVersion}
    done
  fi
}

function main {
  # Scenario:
  # ------------------------------
  # 1. Import the decision service
  # 2. Run Main Scoring test suite
  # 3. Generate and deploy the RuleApps
  # 4. Verify the RuleApps are present in RES
  # 5. Execute a RuleApp in DSR
  # 6. Delete the RuleApps

  authArgs=()
  parse_args "$@"
  setAuthentication

  filename="Loan_Validation_Service.zip"
  # Download Loan_Validation_Service.zip if it does not exist or is not a valid zip file
  unzip -q -t ${filename} > /dev/null 2>&1
  if [[ $? != 0 ]]; then
    echo -n "$(date) - ### Loan_Validation_Service.zip does not exist locally. Downloading...  "
    url="https://github.com/DecisionsDev/odm-for-dev-getting-started/blob/master/Loan%20Validation%20Service.zip?raw=1"
    wget -q ${url} -O ${filename} && echo_success "DONE" || error "ERROR" "Error downloading file from ${url}" $?
  fi

  importDecisionService ${filename}
  decisionServiceId=$(getDecisionServiceId "Loan Validation Service") || error "ERROR" "${decisionServiceId}" $?

  runTestSuite "${decisionServiceId}" "Main Scoring test suite"

  deploymentsList=$(getDeploymentInfo ${decisionServiceId}) || error "ERROR" "${deploymentsList}" $?
  echo "${deploymentsList}" | jq -r '.[] | .id + " " + .ruleAppName + " " + .ruleAppVersion' | while read deploymentId ruleAppName ruleAppVersion; do
    deployRuleApp ${deploymentId} ${ruleAppName} ${ruleAppVersion}
    verifyRuleApp ${ruleAppName} ${ruleAppVersion}
  done

  testRuleSet production_deployment/1.0/loan_validation_production/1.0 loan_validation_test.json loan_validation_test_response.json

  clean ${deploymentsList}
  echo_success "🎉  ODM has been successfully validated!"
}
main "$@"
