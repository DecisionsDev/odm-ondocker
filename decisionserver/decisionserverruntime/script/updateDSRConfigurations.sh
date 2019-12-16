#!/bin/bash

echo "Update Decision Server Runtime configurations"


echo "Enable basic authentication"
cd $APPS/DecisionService.war/WEB-INF;
sed -i $'/<\/web-app>/{e cat /config/basicAuth.xml\n}' web.xml

if [ "$OPENID_CONFIG" == "true" ]
then
  if [ ! -f "/config/auth/openIdParameters.properties" ]
  then
    echo "copy template to /config/auth/openIdParameters.properties"
    mv /config/authOidc/openIdParametersTemplate.properties /config/auth/openIdParameters.properties
    sed -i 's|__OPENID_HOST__|'$OPENID_HOST'|g' /config/auth/openIdParameters.properties
    sed -i 's|__OPENID_PORT__|'$OPENID_PORT'|g' /config/auth/openIdParameters.properties
    sed -i 's|__OPENID_PROVIDER__|'$OPENID_PROVIDER'|g' /config/auth/openIdParameters.properties
    sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/auth/openIdParameters.properties
    sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/auth/openIdParameters.properties
    sed -i 's|__OPENID_ALLOWED_DOMAINS__|'$OPENID_ALLOWED_DOMAINS'|g' /config/auth/openIdParameters.properties
  fi

if [ ! -f "/config/auth/openIdWebSecurity.xml" ]
  then
    echo "copy template to /config/auth/openIdWebSecurity.xml"
    mv /config/authOidc/openIdWebSecurityTemplate.xml /config/auth/openIdWebSecurity.xml
    sed -i 's|__OPENID_HOST__|'$OPENID_HOST'|g' /config/auth/openIdWebSecurity.xml
    sed -i 's|__OPENID_PORT__|'$OPENID_PORT'|g' /config/auth/openIdWebSecurity.xml
    sed -i 's|__OPENID_PROVIDER__|'$OPENID_PROVIDER'|g' /config/auth/openIdWebSecurity.xml
    sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/auth/openIdWebSecurity.xml
    sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/auth/openIdWebSecurity.xml
  fi
fi

if [ -s "/config/auth/openIdParameters.properties" ]
then
	echo "replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
  	sed -i $'/<group name="resExecutors"/{e cat /config/authOidc/resExecutors.xml\n}' /config/application.xml
  	sed -i '/<group name="resExecutors"/d' /config/application.xml
else
  echo "No provided /config/auth/openIdParameters.properties"
  echo "BASIC_AUTH config : remove authFilters from server.xml"
  sed -i '/authFilters/d' /config/server.xml
  echo "BASIC_AUTH config : remove openIdWebSecurity from server.xml"
  sed -i '/openIdWebSecurity/d' /config/server.xml
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

if [ -n "$ENABLE_TLS" ]
then
 echo "Use httpSession settings for HTTPS"
 cp /config/httpSessionHttps.xml /config/httpSession.xml
else
 echo "Use httpSession settings for HTTP"
 cp /config/httpSessionHttp.xml /config/httpSession.xml
fi

if [ -n "$RELEASE_NAME" ]
then
  echo "Prefix decision server console cookie names with $RELEASE_NAME"
        sed -i 's|RELEASE_NAME|'$RELEASE_NAME'|g' /config/httpSession.xml
else
  echo "Prefix decision server console cookie names with $HOSTNAME"
        sed -i 's|RELEASE_NAME|'$HOSTNAME'|g' /config/httpSession.xml
fi
