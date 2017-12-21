#!/bin/bash

echo "Update Decision Center configurations"

if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
  echo "Update dicision server console name to $DECISIONSERVERCONSOLE_NAME in decisioncenter-configuration.properties"
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
if [ -n "$DECISIONRUNNER_NAME" ]
then
  echo "Update dicision runner name to $DECISIONRUNNER_NAME in decisioncenter-configuration.properties"
	sed -i 's|odm-decisionrunner|'$DECISIONRUNNER_NAME'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

if [ -n "$DC_PERSISTENCE_LOCALE" ]
then
	echo "Use DC_PERSISTENCE_LOCALE set to $DC_PERSISTENCE_LOCALE"
	sed -i 's|DC_PERSISTENCE_LOCALE|'$DC_PERSISTENCE_LOCALE'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
  echo "No DC_PERSISTENCE_LOCALE set use default en_US"
	sed -i 's|DC_PERSISTENCE_LOCALE|'en_US'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
