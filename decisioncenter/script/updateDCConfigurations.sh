#!/bin/bash

echo "Update Decision Center configurations"

if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
  echo "Update dicision server console name to $DECISIONSERVERCONSOLE_NAME in decisioncenter-configuration.properties"
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
if [ -n "$DECISIONRUNNER_NAME" ]
then
  echo "Update dicision runner name to $DECISIONRUNNER_NAME in decisioncenter-configuration.properties"
	sed -i 's|odm-decisionrunner|'$DECISIONRUNNER_NAME'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
