#!/bin/bash
if [ -n "$DBSERVER_NAME" ]
then
	sed -i 's|dbserver|'$DBSERVER_NAME'|g' /config/datasource.xml
fi
if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
if [ -n "$DECISIONRUNNER_NAME" ]
then
	sed -i 's|odm-decisionrunner|'$DECISIONRUNNER_NAME'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
/opt/ibm/docker/docker-server run defaultServer
