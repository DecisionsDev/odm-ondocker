#!/usr/bin/env bash

DC_URL=http://localhost:9060
DC_USER=rtsAdmin

function usage {
        cat <<EOF
Usage: $(basename "$0") [-<option letter> <option value>] [-h]

Options:
  -d  # DC URL (default is ${DC_URL})
  -h  # Displays this help page
EOF
  exit 0
}

while getopts "d:h" OPTION; do
  case "$OPTION" in
    d) DC_URL=${OPTARG} ;;
    *) usage ;;
  esac
done

type jq >& /dev/null || (echo "jq must be installed!" && exit 1)

echo -n "$(date) - ### Upload Loan Validation Service to DC:  "
curl_result=$(curl --silent --insecure --request POST "${DC_URL}/decisioncenter-api/v1/decisionservices/import" --header "accept: */*" --header "Content-Type: multipart/form-data" --form "file=@$(dirname "$0")/Loan_Validation_Service_main.zip;type=application/zip" --user ${DC_USER}:${DC_USER})
if [[ $? != 0 ]]; then
  echo "Could not connect to ${DC_URL};  please check that DC is up and running."
  exit 1
fi
status=$(echo ${curl_result} | jq -r '.status')
if [[ "${status}" == "null" ]]; then
  echo "COMPLETED"
else
  echo ${status}
fi
if [[ "${status}" == "BAD_REQUEST" ]]; then
  echo ${curl_result} | jq -r '.reason'
fi

decisionServiceId=$(echo ${curl_result} | jq -r '.decisionService.id')
if [[ "${decisionServiceId}" == "null" ]]; then
  decisionServiceId=4ea8ed3f-98a0-4b25-853c-6cc857215ae8
fi

echo -n "$(date) - ### Upload Shipment Pricing to DC:  "
curl_result=$(curl --silent --insecure --request POST "${DC_URL}/decisioncenter-api/v1/decisionservices/import" --header "accept: */*" --header "Content-Type: multipart/form-data" --form "file=@$(dirname "$0")/Shipment_Pricing_main.zip;type=application/zip" --user ${DC_USER}:${DC_USER})
if [[ $? != 0 ]]; then
  echo "Could not connect to ${DC_URL};  please check that DC is up and running."
  exit 1
fi
status=$(echo ${curl_result} | jq -r '.status')
if [[ "${status}" == "null" ]]; then
  echo "COMPLETED"
else
  echo ${status}
fi
if [[ "${status}" == "BAD_REQUEST" ]]; then
  echo ${curl_result} | jq -r '.reason'
fi

echo -n "$(date) - ### Get elements Ids from DC:  "
elements=$(curl --silent --insecure "${DC_URL}/decisioncenter-api/v1/decisionservices/${decisionServiceId}/deployments" --user ${DC_USER}:${DC_USER})
if [[ $? != 0 ]]; then
  echo "Could not connect to ${DC_URL};  please check that DC is up and running."
  exit 1
fi
echo "DONE"

elementsIds=$(echo ${elements} | jq -r '.elements | map(.id) | .[]')

for elementId in ${elementsIds[@]}; do
  ruleapp_name=$(echo ${elements} | jq -r ".elements[] | select(.id == \"${elementId}\").name")
  echo -n "$(date) - ### Deploy RuleApp ${ruleapp_name} to DC:  "
  curl_result=$(curl --silent --insecure --request POST "${DC_URL}/decisioncenter-api/v1/deployments/${elementId}/deploy" --user ${DC_USER}:${DC_USER})
  echo $curl_result | jq -r '.status'
done

exit 0
