#!/bin/bash

if [ ! -f ${CATALINA_HOME}/initializeddb.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		if [ -d "${CATALINA_HOME}/dbdata/" ]; then
  			cp -R ${CATALINA_HOME}/upload/* ${CATALINA_HOME}/dbdata/
		fi;
	fi;
	touch ${CATALINA_HOME}/initializeddb.flag
fi;

if [ ! -f ${CATALINA_HOME}/initialized.flag ] ; then
	cd  ${CATALINA_HOME}/webapps/DecisionService/WEB-INF/classes;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	touch ${CATALINA_HOME}/initialized.flag
fi;

if [ -n "$COM_IBM_RULES_METERING_ENABLE" ]
then
	cd  ${CATALINA_HOME}/webapps/DecisionService/WEB-INF/classes;
	sed -i 's/{pluginClass=HTDS}/{pluginClass=Metering,enable=true},{pluginClass=DVS},{pluginClass=HTDS}/g' ra.xml
fi

catalina.sh run
