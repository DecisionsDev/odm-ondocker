#!/bin/bash

if [ ! -f /config/initializeddb.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		if [ -d "/config/dbdata/" ]; then
  			cp -R /upload/* /config/dbdata/
		fi;
	fi;
	touch /config/initializeddb.flag
fi;

if [ ! -f /config/initialized.flag ] ; then
	cd  /config/apps/DecisionService.war/WEB-INF/classes;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;	
	touch /config/initialized.flag
fi;

if [ -n "$COM_IBM_RULES_METERING_ENABLE" ] 
then 
	cd  /config/apps/DecisionService.war/WEB-INF/classes;
	sed -i 's/{pluginClass=HTDS}/{pluginClass=Metering,enable=true},{pluginClass=DVS},{pluginClass=HTDS}/g' 	ra.xml
fi

# Begin - Configuration for the database
if [ -n "$DB_DRIVER_URL" ]
then
	echo "Use DB_DRIVER_URL: $DB_DRIVER_URL"
	wget -nv $DB_DRIVER_URL
    case $DB_DRIVER_URL in
      	*postgres* ) rm /config/resources/postgres*
					 mv postgres* /config/resources 
					 cp /config/datasource-postgres.xml /config/datasource.xml 
					 ;; 
	esac
elif [ -n "$DB_TYPE" ]
then
	echo "Use DB_TYPE: $DB_TYPE"
	case $DB_TYPE in
		*h2* ) cp /config/datasource-h2.xml /config/datasource.xml 
			   ;; 
      	*postgres* ) cp /config/datasource-postgres.xml /config/datasource.xml 
					 ;; 
	esac
else
	echo "Use H2 as database by default"
	cp /config/datasource-h2.xml /config/datasource.xml
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

if [ -n "$DC_PERSISTENCE_LOCALE" ]
then
        sed -i 's|DC_PERSISTENCE_LOCALE|'$DC_PERSISTENCE_LOCALE'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
        sed -i 's|DC_PERSISTENCE_LOCALE|'en_US'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

# Begin - Add DC Rest Api Web App
if [ -e /config/apps/decisioncenter-api.war ]
then
       echo “Add DC Rest Api Web App”
       cp -f /config/application-withRestApi.xml /config/decisioncenter_application.xml
else
       echo “DC Rest Api Web App Not Present”
fi
# End - Add DC Rest Api Web App

/opt/ibm/docker/docker-server run defaultServer