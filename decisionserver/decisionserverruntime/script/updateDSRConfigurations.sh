#!/bin/bash

echo "Update Decision Server Runtime configurations"


echo "Enable basic authentication"
cd $APPS/DecisionService.war/WEB-INF;
sed -i $'/<\/web-app>/{e cat /config/basicAuth.xml\n}' web.xml

if [ -s "/config/auth/runtimeWebSecurity.xml" ]
then
   echo "/config/auth/runtimeWebSecurity.xml found then replace oidc auth by basic auth on decision server runtime"
   sed -i 's|webSecurity|'runtimeWebSecurity'|g' /config/server.xml
   unset OPENID_CONFIG
   echo "OPENID_CONFIG : $OPENID_CONFIG"
fi


if [ -n "$OPENID_CONFIG" ]
then
  if [ -s "/config/auth/openIdParameters.properties" ]
  then
    echo "copy provided /config/auth/openIdParameters.properties to /config/authOidc/openIdParameters.properties"
    cp /config/auth/openIdParameters.properties /config/authOidc/openIdParameters.properties
  else
    echo "copy template to /config/authOidc/openIdParameters.properties"
    mv /config/authOidc/openIdParametersTemplate.properties /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_SERVER_URL__|'$OPENID_SERVER_URL'|g' /config/authOidc/openIdParameters.properties
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
    sed -i 's|__OPENID_SERVER_URL__|'$OPENID_SERVER_URL'|g' /config/authOidc/openIdWebSecurity.xml
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
  echo "BASIC_AUTH config : remove oidcClientWebapp from server.xml"
  sed -i '/oidcClientWebapp/d' /config/server.xml

  if [ -n "$DSR_ROLE_GROUP_MAPPING" ]
  then
    echo "DSR_ROLE_GROUP_MAPPING set then replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
    sed -i $'/<group name="resExecutors"/{e cat /config/authOidc/resExecutors.xml\n}' /config/application.xml
    sed -i '/<group name="resExecutors"/d' /config/application.xml
  fi
fi

cd  $APPS/DecisionService.war/WEB-INF/classes;
echo "Set XU log level to WARNING"
sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;


if [ -n $CONNECTION_POOL_SIZE ]; then
        if [ -n "$CONNECTION_POOL_TIMEOUT" ]
        then
                echo "Configure XU connection pool size to $CONNECTION_POOL_SIZE and XU connection pool timeout to $CONNECTION_POOL_TIMEOUT"
                sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout='$CONNECTION_POOL_TIMEOUT'</config-property-value>|' ra.xml;
        else
		echo "Configure XU connection pool size to $CONNECTION_POOL_SIZE"
		sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	fi
else
	echo "The environment variable CONNECTION_POOL_SIZE is not configured."
	exit 1
fi

function updateXuPropertyInRaXml() {
	result="$(xmllint --shell ra.xml 2>&1 >/dev/null << EOF
setns x=http://java.sun.com/xml/ns/j2ee
cd x:connector/x:resourceadapter/x:outbound-resourceadapter/x:connection-definition/x:config-property[x:config-property-name='$1']/x:config-property-value
set $value
save
EOF
)"
	if [[ "$result" != *"error"* ]]; then
		echo "Setting property $key to $value in the ra.xml file"
	else
		echo "Unable to set property $key in the ra.xml file"
	fi
}

if [ -f "/config/xu-configuration.properties" ]; then
	echo "Configure XU properties"
	file="/config/xu-configuration.properties"
	while IFS='=' read -r key value
	do
    # Check if non blank or commented line
    if [ -n "$key" ] && [[ "$key" != "#"* ]]; then
      updateXuPropertyInRaXml "$key" "$value"
    fi
  done < <(grep . "$file")
else
  echo "No XU configuration file provided"
fi

if [ -f "/config/baiemitterconfig/plugin-configuration.properties" ]; then
	echo "Enable BAI Emitter Plugin"
        sed -i 's/{pluginClass=HTDS}/&,{pluginClass=ODMEmitterForBAI}/' ra.xml;
        if [ -f "/config/pluginconfig/plugin-configuration.properties" ]; then
                echo "concat BAI Emitter and Metering plugins"
                cat /config/baiemitterconfig/plugin-configuration.properties >> /config/pluginconfig/plugin-configuration.properties
        else
                echo "create plugin directory /config/pluginconfig"
                mkdir /config/pluginconfig
                cp /config/baiemitterconfig/plugin-configuration.properties /config/pluginconfig/plugin-configuration.properties
        fi
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
