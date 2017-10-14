#!/bin/bash
if [ ! -f /config/initialized.flag ] ; then
	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
    sed -i 's|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin}|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin},{pluginClass=Metering}|g' ra.xml;
	touch /config/initialized.flag
fi;

if [ -n "$DBSERVER_NAME" ] 
then 
	sed -i 's|dbserver|'$DBSERVER_NAME'|g' /config/datasource.xml
fi

if [ "$REGISTRY" = "ldap" ]
then
	echo "Use LDAP registry"
	cp /config/webSecurity-ldap.xml /config/webSecurity.xml
else
	echo "Use basic registry"
	cp /config/webSecurity-basic.xml /config/webSecurity.xml
fi

/opt/ibm/docker/docker-server run defaultServer
