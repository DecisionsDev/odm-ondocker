#!/bin/bash

echo "Update Decision Server Console configurations"

if [ -n "$DECISION_SERVICE_URL" ]
then
	sed -i 's|/DecisionService|'$DECISION_SERVICE_URL'|g' $APPS/res.war/WEB-INF/web.xml
else
	sed -i 's|/DecisionService|http://localhost:9090/DecisionService|g' $APPS/res.war/WEB-INF/web.xml
fi
