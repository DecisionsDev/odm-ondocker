#!/bin/bash
if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
if [ -n "$DECISIONRUNNER_NAME" ]
then
	sed -i 's|odm-decisionrunner|'$DECISIONRUNNER_NAME'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

if [ -n "$DC_PERSISTENCE_LOCALE" ]
then
        sed -i 's|DC_PERSISTENCE_LOCALE|'$DC_PERSISTENCE_LOCALE'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
        sed -i 's|DC_PERSISTENCE_LOCALE|'en_US'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
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
if [ -n "$DB_DRIVER_URL" ]
then
	echo "Use DB_DRIVER_URL: $DB_DRIVER_URL"
	wget -nv $DB_DRIVER_URL
    case $DB_DRIVER_URL in
    	*derby* ) rm /config/resources/derby*
				  mv derby* /config/resources 
				  cp /config/datasource-derby.xml /config/datasource.xml 
				  ;;
      	*mysql* ) rm /config/resources/mysql*
				  mv mysql* /config/resources 
				  cp /config/datasource-mysql.xml /config/datasource.xml 
				  ;;
      	*postgres* ) rm /config/resources/postgres*
					 mv postgres* /config/resources 
					 cp /config/datasource-postgres.xml /config/datasource.xml 
					 ;; 
		*db2* ) rm /config/resources/db2*
				mv db2* /config/resources 
				cp /config/datasource-db2.xml /config/datasource.xml 
				;; 
	esac
elif [ -n "$DB_TYPE" ]
then
	echo "Use DB_TYPE: $DB_TYPE"
	case $DB_TYPE in
		*derby* ) if [ ! -f /config/resources/derby* ]; then  /script/installDerby.sh; fi
				  cp /config/datasource-derby.xml /config/datasource.xml 
				  ;;
		*mysql* ) if [ ! -f /config/resources/mysql* ]; then /script/installMySQL.sh; fi
				  cp /config/datasource-mysql.xml /config/datasource.xml 
				  ;;
		# For postgreSQL, we do not have to install the driver here since it is installed by default at build time
      	*postgres* ) cp /config/datasource-postgres.xml /config/datasource.xml 
					 ;;
		# For DB2, we do not have to install the driver here since it is supposed to be provided through the drivers folder at build time
		*db2* ) cp /config/datasource-db2.xml /config/datasource.xml 
				;;
	esac
else
	echo "Use PostgreSQL as database by default"
	cp /config/datasource-postgres.xml /config/datasource.xml
fi
# End - Configuration for the database

# Begin - Change values for the datasource if required
if [ -n "$DB_SERVER_NAME" ] 
then 
	sed -i 's|dbserver|'$DB_SERVER_NAME'|g' /config/datasource.xml
fi
if [ -n "$DB_PORT_NUMBER" ] 
then 
	sed -i 's|5432|'$DB_PORT_NUMBER'|g' /config/datasource.xml
fi
if [ -n "$DB_NAME" ] 
then 
	sed -i 's|odmdb|'$DB_NAME'|g' /config/datasource.xml
fi
if [ -n "$DB_USER" ] 
then 
	sed -i 's|odmusr|'$DB_USER'|g' /config/datasource.xml
fi
if [ -n "$DB_PASSWORD" ] 
then 
	sed -i 's|odmpwd|'$DB_PASSWORD'|g' /config/datasource.xml
fi
# End - Change values for the datasource if required

# Begin - Add DC Rest Api Web App
if [ -e /config/apps/decisioncenter-api.war ]
then
        echo "Add DC Rest Api Web App"
        cp /config/application-withRestApi.xml /config/application.xml
else
        echo "DC Rest Api Web App Not Present"
fi
# End - Add DC Rest Api Web App

/opt/ibm/docker/docker-server run defaultServer
