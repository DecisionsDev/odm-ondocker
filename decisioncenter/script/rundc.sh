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

if [ "$REGISTRY" = "ldap" ]
then
	echo "Use LDAP registry"
	cp /config/webSecurity-ldap.xml /config/webSecurity.xml
	perl -i -p0e 's/(com\.ibm\.rules\.decisioncenter\.setup\.ldap-configurations=)(.*?)/\1\/config\/ldap-configurations\.xml/s' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
	perl -i -p0e 's/(com\.ibm\.rules\.decisioncenter\.setup\.group-security-configurations=)(\/config\/group-security-configurations\.xml)/\1/s' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
	echo "Use basic registry"
	cp /config/webSecurity-basic.xml /config/webSecurity.xml
fi

/opt/ibm/docker/docker-server run defaultServer
