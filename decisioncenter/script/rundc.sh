#!/bin/bash
#if [ ! -f /config/initialized.flag ] ; then
#	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
#	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
#	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
#	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
#   sed -i 's|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin}|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin},{pluginClass=Metering}|g' ra.xml;
#	touch /config/initialized.flag
#fi;

echo "LDAP environment variable: $LDAP"

if [ "$LDAP" = "true" ]
then
	cp /config/webSecurity-ldap.xml /config/webSecurity.xml
	perl -i -p0e 's/(com\.ibm\.rules\.decisioncenter\.setup\.ldap-configurations=)(.*?)/\1\/config\/ldap-configurations\.xml/s' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
	#com.ibm.rules.decisioncenter.setup.ldap-configurations=
	#sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	#perl -i -p0e 's/(<param-name>com\.ibm\.rules\.decisioncenter\.setup\.configuration-file<\/param-name>.*?<param-value>)(.*?)(<\/param-value>)/\1\/config\/decisioncenter-configuration\.properties\3/s' /config/apps/decisioncenter.war/WEB-INF/web.xml
else
	cp /config/webSecurity-basic.xml /config/webSecurity.xml
	perl -i -p0e 's/(com\.ibm\.rules\.decisioncenter\.setup\.ldap-configurations=)(.*?)/\1/s' /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

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

/opt/ibm/docker/docker-server run defaultServer
