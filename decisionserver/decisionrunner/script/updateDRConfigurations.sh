#!/bin/bash

echo "Update Decision Runner configurations"

if [ ! -f /config/initialized.flag ] ; then
	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
    sed -i 's|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin}|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin},{pluginClass=Metering}|g' ra.xml;
    perl -i -p0e 's/(<param-name>RES_URL<\/param-name>.*?)(<param-value\/>)/\1<param-value><\/param-value>/s' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
    perl -i -p0e 's/(<param-name>RES_URL<\/param-name>.*?<param-value>)(.*?)(<\/param-value>)/\1protocol:\/\/odm-decisionserverconsole:decisionserverconsole-port\/res\3/s' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
	touch /config/initialized.flag
fi;

if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/DecisionRunner.war/WEB-INF/classes/ra.xml;
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
fi

if [ -n "$ENABLE_TLS" ]
then
 echo "Update decision server protocol to https in web.xml"
        sed -i 's|protocol|'https'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
else
 echo "Update decision server protocol to http in web.xml"
        sed -i 's|protocol|'http'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
fi

if [ -n "$DECISIONSERVERCONSOLE_PORT" ]
then
  echo "Update decision server console port to $DECISIONSERVERCONSOLE_PORT in web.xml"
        sed -i 's|decisionserverconsole-port|'$DECISIONSERVERCONSOLE_PORT'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
else
  echo "Update decision server console port to default 9080 in web.xml"
        sed -i 's|decisionserverconsole-port|'9080'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
fi
