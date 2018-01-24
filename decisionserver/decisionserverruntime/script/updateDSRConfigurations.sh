#!/bin/bash

echo "Update Decision Server Runtime configurations"

if [ -z $CONNECTION_POOL_SIZE ]; then
	echo "The environment variable CONNECTION_POOL_SIZE is not configured."
	exit 1
fi

if [ ! -f /config/initialized.flag ] ; then
	cd /config/apps/DecisionService.war/WEB-INF;
	sed -i $'/<\/web-app>/{e cat /config/basicAuth.xml\n}' web.xml

	cd  $APPS/DecisionService.war/WEB-INF/classes;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	touch /config/initialized.flag
fi;
