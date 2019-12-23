#!/bin/bash

echo "Update Decision Server Runtime configurations"


echo "Enable basic authentication"
cd $APPS/DecisionService.war/WEB-INF;
sed -i $'/<\/web-app>/{e cat /config/basicAuth.xml\n}' web.xml

if [ -n "$OPENID_CONFIG" ]
then
  if [ -s "/config/auth/openIdParameters.properties" ]
  then
    echo "copy provided /config/auth/openIdParameters.properties to /config/authOidc/openIdParameters.properties"
    cp /config/auth/openIdParameters.properties /config/authOidc/openIdParameters.properties
  else
    echo "copy template to /config/authOidc/openIdParameters.properties"
    mv /config/authOidc/openIdParametersTemplate.properties /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_HOST__|'$OPENID_HOST'|g' /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_PORT__|'$OPENID_PORT'|g' /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_PROVIDER__|'$OPENID_PROVIDER'|g' /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_ALLOWED_DOMAINS__|'$OPENID_ALLOWED_DOMAINS'|g' /config/authOidc/openIdParameters.properties
  fi
  sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/authOidc/openIdParameters.properties
  sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/authOidc/openIdParameters.properties

if [ -s "/config/auth/openIdWebSecurity.xml" ]
  then
    echo "copy provided /config/auth/openIdWebSecurity.xml to /config/authOidc/openIdWebSecurity.xml"
    cp /config/auth/openIdWebSecurity.xml /config/authOidc/openIdWebSecurity.xml
  else
    echo "copy template to /config/authOidc/openIdWebSecurity.xml"
    mv /config/authOidc/openIdWebSecurityTemplate.xml /config/authOidc/openIdWebSecurity.xml
    sed -i 's|__OPENID_HOST__|'$OPENID_HOST'|g' /config/authOidc/openIdWebSecurity.xml
    sed -i 's|__OPENID_PORT__|'$OPENID_PORT'|g' /config/authOidc/openIdWebSecurity.xml
    sed -i 's|__OPENID_PROVIDER__|'$OPENID_PROVIDER'|g' /config/authOidc/openIdWebSecurity.xml
  fi
  sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/authOidc/openIdWebSecurity.xml
  sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/authOidc/openIdWebSecurity.xml
fi

if [ -s "/config/authOidc/openIdParameters.properties" ]
then
	echo "replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
  	sed -i $'/<group name="resExecutors"/{e cat /config/authOidc/resExecutors.xml\n}' /config/application.xml
  	sed -i '/<group name="resExecutors"/d' /config/application.xml
else
  echo "No provided /config/authOidc/openIdParameters.properties"
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

if [ -f "/config/xu-configuration.properties" ]; then
	echo "Configure XU properties"
	file="/config/xu-configuration.properties"
	while IFS='=' read -r key value
	do
    echo "Set property ${key} to ${value} in the ra.xml file"
    xmllint --shell ra.xml << EOF
setns x=http://java.sun.com/xml/ns/j2ee
cd x:connector/x:resourceadapter/x:outbound-resourceadapter/x:connection-definition/x:config-property[x:config-property-name='${key}']/x:config-property-value
set ${value}
save
EOF
  done < "$file"
else
  echo "No XU configuration file provided"
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
