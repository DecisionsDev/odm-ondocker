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
	sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	touch ${CATALINA_HOME}/initialized.flag
fi;

if [ -n "$COM_IBM_RULES_METERING_ENABLE" ]
then
	cd  ${CATALINA_HOME}/webapps/DecisionService/WEB-INF/classes;
	sed -i 's/{pluginClass=HTDS}/{pluginClass=Metering,enable=true},{pluginClass=DVS},{pluginClass=HTDS}/g' ra.xml
fi

FIND_SERVER_EXT_CLASS="$($SCRIPT/findServerExtClass.sh)"
echo "FIND_SERVER_EXT_CLASS set to $FIND_SERVER_EXT_CLASS"

if [ "$FIND_SERVER_EXT_CLASS" == "matches" ]
then
  echo "Update decisioncenter-configuration.properties with ${CATALINA_HOME}/conf/server-configurations.json"
	cd $APPS/decisioncenter/WEB-INF/classes/config
        cp ${CATALINA_HOME}/conf/new-decisioncenter-configuration.properties decisioncenter-configuration.properties
        sed -i "s|CATALINA_HOME|$CATALINA_HOME|g" decisioncenter-configuration.properties
else
  echo "Use old decisioncenter-configuration.properties definition"
        cp ${CATALINA_HOME}/new-decisioncenter-configuration.properties $APPS/decisioncenter/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

catalina.sh run
