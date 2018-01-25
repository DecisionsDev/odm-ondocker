#!/bin/bash

echo "Update Decision Server Console configurations"

if [ -z "$DECISION_SERVICE_URL" ]; then
	echo "ERROR: The environment variable DECISION_SERVICE_URL is not configured. It specifies the URL of Decision Service Runtime in Decision Service Console."
	exit 1
fi

sed -i 's|/DecisionService|'$DECISION_SERVICE_URL'|g' $APPS/res.war/WEB-INF/web.xml
