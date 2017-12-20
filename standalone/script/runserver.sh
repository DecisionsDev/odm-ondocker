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

$SCRIPT/enableMetering.sh

$SCRIPT/configureDatabase.sh h2

$SCRIPT/changeDatasource.sh

if [ -n "$DC_PERSISTENCE_LOCALE" ]
then
        echo "use DC_PERSISTENCE_LOCALE set to $DC_PERSISTENCE_LOCALE"
		sed -i 's|DC_PERSISTENCE_LOCALE|'$DC_PERSISTENCE_LOCALE'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
        echo "no DC_PERSISTENCE_LOCALE set use default en_US"
		sed -i 's|DC_PERSISTENCE_LOCALE|'en_US'|g' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/addRestApi.sh

/opt/ibm/docker/docker-server run defaultServer
