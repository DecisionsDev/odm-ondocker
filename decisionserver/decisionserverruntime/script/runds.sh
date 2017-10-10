#!/bin/bash
set -x
if [ ! -f /config/initialized.flag ] ; then
	cd /config/apps/DecisionService.war/WEB-INF;
	sed -i $'/<\/web-app>/{e cat /config/basicAuth.xml\n}' web.xml

	cd  /config/apps/DecisionService.war/WEB-INF/classes;
	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	touch /config/initialized.flag
fi;


if [ -n "$DBSERVER_NAME" ]
then
	sed -i 's|dbserver|'$DBSERVER_NAME'|g' /config/datasource.xml
fi;
if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/DecisionService.war/WEB-INF/classes/ra.xml;
fi
if [ -n "$COM_IBM_RULES_METERING_ENABLE" ]
then
	cd  /config/apps/DecisionService.war/WEB-INF/classes;
	sed -i 's/{pluginClass=HTDS}/{pluginClass=Metering,enable=true},{pluginClass=DVS},{pluginClass=HTDS}/g' 	ra.xml
fi;

/opt/ibm/docker/docker-server run defaultServer
