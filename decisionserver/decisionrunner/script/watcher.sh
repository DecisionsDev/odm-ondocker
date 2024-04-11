#!/usr/bin/env sh

RESTART=true
SECRETS_MOUNT_POINT=/mnt/secrets

SECRETS_SUM=$(cat $(find ${SECRETS_MOUNT_POINT} -type f | sort) | sha1sum | awk '{print $1}')
echo "Secret sum: ${SECRETS_SUM}"

OLD_SECRETS_SUM=$(kubectl get configmap ${BEACON_NAME} -o jsonpath='{.data.secrets_sum}')
echo "Old secret sum: ${OLD_SECRETS_SUM}"

if [[ ! ${OLD_SECRETS_SUM} ]]; then RESTART=false; fi

if [[ "${OLD_SECRETS_SUM}" != "${SECRETS_SUM}" ]]; then
    kubectl patch configmap ${BEACON_NAME} -p "{\"data\":{\"secrets_sum\":\"${SECRETS_SUM}\"}}"
    if [[ ${RESTART} = true ]]; then
        PODS_TO_DELETE=$(kubectl get pods --selector "release=${RELEASE_NAME},run in (${RELEASE_NAME}-dbserver,${RELEASE_NAME}-odm-decisioncenter,${RELEASE_NAME}-odm-decisionrunner,${RELEASE_NAME}-odm-decisionserverconsole,${RELEASE_NAME}-odm-decisionserverruntime)" --no-headers --output custom-columns=":metadata.name")
        echo "Restart pods ${PODS_TO_DELETE}:"
        kubectl delete pods ${PODS_TO_DELETE}
    fi
fi

exit 0
