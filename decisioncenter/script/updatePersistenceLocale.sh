#!/bin/bash

if [ -n "$DC_PERSISTENCE_LOCALE" ]
then
	echo "Use DC_PERSISTENCE_LOCALE set to $DC_PERSISTENCE_LOCALE"
	sed -i 's|DC_PERSISTENCE_LOCALE|'$DC_PERSISTENCE_LOCALE'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
  echo "No DC_PERSISTENCE_LOCALE set use default en_US"
	sed -i 's|DC_PERSISTENCE_LOCALE|'en_US'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
