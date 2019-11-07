#!/bin/bash

echo "Update Decision Server Runtime configurations"


echo "Enable basic authentication"
cd $APPS/DecisionService.war/WEB-INF;
sed -i $'/<\/web-app>/{e cat /config/basicAuth.xml\n}' web.xml

if [ -s "/config/auth/openIdParameters.properties" ]
then
	echo "replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
  	sed -i $'/<group name="resExecutors"/{e cat /config/authOidc/resExecutors.xml\n}' /config/application.xml
  	sed -i '/<group name="resExecutors"/d' /config/application.xml
else
  echo "No provided /config/auth/openIdParameters.properties"
fi

cd  $APPS/DecisionService.war/WEB-INF/classes;
echo "Set XU log level to WARNING"
sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;


if [ -n $CONNECTION_POOL_SIZE ]; then
	echo "Configure XU connection pool size to $CONNECTION_POOL_SIZE"
	sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
else
	echo "The environment variable CONNECTION_POOL_SIZE is not configured."
	exit 1
fi

if [ -f "/config/baiemitterconfig/plugin-configuration.properties" ]; then
	echo "Enable BAI Emitter Plugin"
        sed -i 's/{pluginClass=HTDS}/&,{pluginClass=ODMEmitterForBAI}/' ra.xml;
fi

if [ -f "/config/baiemitterconfig/krb5.conf" ]; then
	echo "Configure Kerberos authentication"
	echo "-Djava.security.krb5.conf=/config/baiemitterconfig/krb5.conf" >> /config/jvm.options
fi

if [ -n "$RELEASE_NAME" ]
then
  echo "Prefix decision server console cookie names with $RELEASE_NAME"
        sed -i 's|RELEASE_NAME|'$RELEASE_NAME'|g' /config/httpSession.xml
else
  echo "Prefix decision server console cookie names with $HOSTNAME"
        sed -i 's|RELEASE_NAME|'$HOSTNAME'|g' /config/httpSession.xml
fi

if [ -n "$ENABLE_TLS" ]
then
 echo "Use httpSession settings for HTTPS"
 cp /config/httpSessionHttps.xml /config/httpSession.xml
else
 echo "Use httpSession settings for HTTP"
 cp /config/httpSessionHttp.xml /config/httpSession.xml
fi
