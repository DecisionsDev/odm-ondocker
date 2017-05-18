#!/bin/bash

if [ ! -f /config/initializeddb.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		if [ -d "/config/dbdata/" ]; then
  		# Control will enter here if $DIRECTORY exists.
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

/opt/ibm/docker/docker-server run defaultServer