#!/bin/bash

echo "Update Decision Server Runtime configurations"


echo "Enable basic authentication"
cd $APPS/DecisionService.war/WEB-INF;
sed -i $'/<\/web-app>/{e cat /config/basicAuth.xml\n}' web.xml

if [ -s "/config/auth/runtimeWebSecurity.xml" ]
then
   if [ ! -d "/config/apps/res.war" ]
   then
   	echo "/config/auth/runtimeWebSecurity.xml found then replace oidc auth by basic auth on decision server runtime"
   	sed -i 's|webSecurity|'runtimeWebSecurity'|g' /config/server.xml
   	unset OPENID_CONFIG
   	echo "OPENID_CONFIG : $OPENID_CONFIG"
   else
	echo "/config/auth/runtimeWebSecurity.xml found in the RES container. Do nothing."	
   fi
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
  # Set env var if secrets are passed using mounted volumes
  [ -f /config/secrets/oidc-config/clientId ] && export OPENID_CLIENT_ID=$(cat /config/secrets/oidc-config/clientId)
  [ -f /config/secrets/oidc-config/clientSecret ] && export OPENID_CLIENT_SECRET=$(cat /config/secrets/oidc-config/clientSecret)
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
  # Set env var if secrets are passed using mounted volumes
  [ -f /config/secrets/oidc-config/clientId ] && export OPENID_CLIENT_ID=$(cat /config/secrets/oidc-config/clientId)
  [ -f /config/secrets/oidc-config/clientSecret ] && export OPENID_CLIENT_SECRET=$(cat /config/secrets/oidc-config/clientSecret)
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
                echo "copy BAIEmmiter config to /config/extension"
		mkdir /config/extension
                cp /config/baiemitterconfig/plugin-configuration.properties /config/extension/plugin-configuration.properties
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

function updateContextParamPropertyInWebXml() {
  if grep -q "<param-name>$1</param-name>" $APPS/DecisionService.war/WEB-INF/web.xml; then
    echo "Setting parameter $1 to $2 in the web.xml file"
	  result="$(xmllint --shell $APPS/DecisionService.war/WEB-INF/web.xml 2>&1 >/dev/null << EOF
setns x=http://java.sun.com/xml/ns/j2ee
cd x:web-app/x:context-param[x:param-name='$1']/x:param-value
set $2
save
EOF
)"
	else
    echo "Adding context-param $1 with value $2 in the web.xml file"
    sed -i '/<\/web-app>/i\
	<context-param>\
		<param-name>'$1'</param-name>\
		<param-value>'$2'</param-value>\
	</context-param>
    ' $APPS/DecisionService.war/WEB-INF/web.xml

	fi
}

if [ -f "/config/web-configuration.properties" ]; then
	echo "Configure context-param properties in web.xml"
	file="/config/web-configuration.properties"
	while IFS='=' read -r key value
	do
    # Check if non blank or commented line
    if [ -n "$key" ] && [[ "$key" != "#"* ]]; then
      updateContextParamPropertyInWebXml "$key" "$value"
    fi
  done < <(grep . "$file")
else
  echo "No web.xml configuration file provided"
fi

if [ -n "$ENABLE_TLS_AUTH" ] && [ "$ENABLE_TLS_AUTH" = true ]; then
	echo "Configure HTTPS Client Authentication in web.xml"
    result="$(xmllint --shell $APPS/DecisionService.war/WEB-INF/web.xml 2>&1 >/dev/null << EOF
setns x=http://java.sun.com/xml/ns/j2ee
cd x:web-app/x:login-config/x:auth-method
set CLIENT-CERT
save
EOF
)"
else
  echo "Use default HTTP Basic Authentication in web.xml"
fi

if [ -s "/config/monitor/monitor.xml" ]
then
  echo "/config/monitor/monitor.xml found! Configure monitoring"
else
  echo "No /config/monitor/monitor.xml ! Disable monitoring"
  sed -i '/monitor/d' /config/server.xml
  sed -i '/mpMetrics/d' /config/featureManager.xml
fi

if [ -s "/config/logstashCollector/logstashCollector.xml" ]
then
  echo "/config/logstashCollector/logstashCollector.xml found! Configure logstashCollector"
else
  echo "No /config/logstashCollector/logstashCollector.xml ! Disable logstashCollector"
  sed -i '/logstashCollector/d' /config/server.xml
  sed -i '/logstashCollector/d' /config/featureManager.xml
fi

if [ -n "$ENABLE_AUDIT" ]
then
  echo "audit is enabled"
else
  echo "audit is disabled"
  sed -i '/audit/d' /config/featureManager.xml
fi
