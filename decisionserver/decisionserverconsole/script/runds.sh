#!/bin/bash
set -x
if [ -n "$DECISION_SERVICE_URL" ] 
then 
	sed -i 's|/DecisionService|'$DECISION_SERVICE_URL'|g' /config/apps/res.war/WEB-INF/web.xml 
else 
	sed -i 's|/DecisionService|http://localhost:9090/DecisionService|g' /config/apps/res.war/WEB-INF/web.xml 
fi
if [ -n "$DBSERVER_NAME" ] 
then 
	sed -i 's|dbserver|'$DBSERVER_NAME'|g' /config/datasource.xml
fi

# Begin - Configuration for the user registry
if [ "$REGISTRY" = "ldap" ]
then
	echo "Use LDAP registry"
	cp /config/webSecurity-ldap.xml /config/webSecurity.xml
else
	echo "Use basic registry"
	cp /config/webSecurity-basic.xml /config/webSecurity.xml
fi
# End - Configuration for the user registry

# Begin - Configuration for the database
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