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

# Begin - Configuration for the user registry
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
# End - Configuration for the user registry

# Begin - Configuration for the database
#ARG DRIVER_URL
#ENV DRIVER_URL $DRIVER_URL
echo "DRIVER_URL: $DRIVER_URL"
echo "POSTGRES: $DRIVER_URL_POSTGRES"

if [ -n "$DRIVER_URL" ]
then
    case $DRIVER_URL in
      *derby* ) wget -nv $DRIVER_URL
				mv derby* /config/resources 
				cp /config/datasource-derby.xml /config/datasource.xml 
				;;
      *mysql* ) wget -nv $DRIVER_URL
				mv mysql* /config/resources 
				cp /config/datasource-mysql.xml /config/datasource.xml 
				;;
      *postgresql* ) cp /config/datasource-postgres.xml /config/datasource.xml 
					 ;; 
	esac
else
	echo "Use PostgreSQL as database by default"
	cp /config/datasource-postgres.xml /config/datasource.xml
fi
# End - Configuration for the database

/opt/ibm/docker/docker-server run defaultServer
