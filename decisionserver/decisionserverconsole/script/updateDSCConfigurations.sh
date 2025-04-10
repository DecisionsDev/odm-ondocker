#!/bin/bash

if [ -n "$DECISION_SERVICE_URL" ]; then
	echo "Update DECISION_SERVICE_URL to $DECISION_SERVICE_URL in Decision Server Console."
	sed -i 's|>.*/DecisionService|>'$DECISION_SERVICE_URL'|g' $APPS/res.war/WEB-INF/web.xml
fi

if [ -f "/config/baiemitterconfig/plugin-configuration.properties" ]; then
        echo "Enable BAI Emitter Plugin"
        sed -i 's/{pluginClass=HTDS}/&,{pluginClass=ODMEmitterForBAI}/' ra.xml
fi

if [ -f "/config/baiemitterconfig/krb5.conf" ]; then
	echo "Configure Kerberos authentication"
	echo "-Djava.security.krb5.conf=/config/baiemitterconfig/krb5.conf" >> /config/jvm.options
fi

if [ -n "$OPENID_CONFIG" ]
then
  if [ -n "$DISABLE_LOGIN_PANEL" ]
  then
    echo "disable RES Console Basic Auth Login Panel"
    sed -i 's|<auth-method>FORM|<auth-method>BASIC|' /config/apps/res.war/WEB-INF/web.xml
  fi

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
  sed -i $'/<group name="resAdministrators"/{e cat /config/authOidc/resAdministrators.xml\n}' /config/application.xml
  sed -i '/<group name="resAdministrators"/d' /config/application.xml
  sed -i $'/<group name="resDeployers"/{e cat /config/authOidc/resDeployers.xml\n}' /config/application.xml
  sed -i '/<group name="resDeployers"/d' /config/application.xml
  sed -i $'/<group name="resMonitors"/{e cat /config/authOidc/resMonitors.xml\n}' /config/application.xml
  sed -i '/<group name="resMonitors"/d' /config/application.xml
  sed -i $'/<group name="resExecutors"/{e cat /config/authOidc/resExecutors.xml\n}' /config/application.xml
  sed -i '/<group name="resExecutors"/d' /config/application.xml

  echo "Enable OpenId authentication"
  OPENID_ALLOWED_DOMAINS=$(grep OPENID_ALLOWED_DOMAINS /config/authOidc/openIdParameters.properties | sed "s/OPENID_ALLOWED_DOMAINS=//g")
  echo "OPENID_ALLOWED_DOMAINS: $OPENID_ALLOWED_DOMAINS"
  OPENID_LOGOUT_URL=$(grep OPENID_LOGOUT_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_LOGOUT_URL=//g")
  OPENID_LOGOUT_TOKEN_PARAM=$(grep OPENID_LOGOUT_TOKEN_PARAM /config/authOidc/openIdParameters.properties | sed "s/OPENID_LOGOUT_TOKEN_PARAM=//g")
  if [ -n "$OPENID_LOGOUT_URL" ]; then
  	echo "OPENID_LOGOUT_URL: $OPENID_LOGOUT_URL"
	if [ -n "$OPENID_LOGOUT_TOKEN_PARAM" ]; then
	        echo "OPENID_LOGOUT_TOKEN_PARAM: $OPENID_LOGOUT_TOKEN_PARAM"
		sed -i 's|type=local|'type=openid,logoutUrl=$OPENID_LOGOUT_URL,logoutTokenParam=$OPENID_LOGOUT_TOKEN_PARAM'|g' $APPS/res.war/WEB-INF/web.xml
	else
		sed -i 's|type=local|'type=openid,logoutUrl=$OPENID_LOGOUT_URL'|g' $APPS/res.war/WEB-INF/web.xml
	fi
  else
	sed -i 's|type=local|'type=openid'|g' $APPS/res.war/WEB-INF/web.xml
  fi
  sed -i 's|OPENID_ALLOWED_DOMAINS|'$OPENID_ALLOWED_DOMAINS'|g' /config/oAuth.xml
  sed -i $'/<\/web-app>/{e cat /config/oAuth.xml\n}' $APPS/res.war/WEB-INF/web.xml
else
  echo "No provided /config/authOidc/openIdParameters.properties"
  echo "BASIC_AUTH config : remove authFilters from server.xml"
  sed -i '/authFilters/d' /config/server.xml
  echo "BASIC_AUTH config : remove openIdWebSecurity from server.xml"
  sed -i '/openIdWebSecurity/d' /config/server.xml
  echo "BASIC_AUTH config : remove oidcClientWebapp from server.xml"
  sed -i '/oidcClientWebapp/d' /config/server.xml

  if [ -n "$DSC_ROLE_GROUP_MAPPING" ]
  then
    echo "DSC_ROLE_GROUP_MAPPING set then replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
    sed -i $'/<group name="resAdministrators"/{e cat /config/authOidc/resAdministrators.xml\n}' /config/application.xml
    sed -i '/<group name="resAdministrators"/d' /config/application.xml
    sed -i $'/<group name="resDeployers"/{e cat /config/authOidc/resDeployers.xml\n}' /config/application.xml
    sed -i '/<group name="resDeployers"/d' /config/application.xml
    sed -i $'/<group name="resMonitors"/{e cat /config/authOidc/resMonitors.xml\n}' /config/application.xml
    sed -i '/<group name="resMonitors"/d' /config/application.xml
    sed -i $'/<group name="resExecutors"/{e cat /config/authOidc/resExecutors.xml\n}' /config/application.xml
    sed -i '/<group name="resExecutors"/d' /config/application.xml
  fi
fi

if [ -n "$ENABLE_TLS" ]
then
 echo "Use httpSession settings for HTTPS"
 cp /config/httpSessionHttps.xml /config/httpSession.xml
else
 echo "Use httpSession settings for HTTP"
 cp /config/httpSessionHttp.xml /config/httpSession.xml
fi
if [[ $ENABLE_FIPS =~ "true" ]]
then
  echo "FIPS Enabled : update the ltpa element in httpSession.xml"
  sed -i 's|keysFileName="${server.config.dir}/resources/security/ltpa.keys".*/>|keysFileName="${server.config.dir}/resources/security/ltpa-FIPS140-3.keys" keysPassword="{aes}ARCRM0U6arPJbg7KEDjSehlpyLgtJs+G+dPl2P19l8YrLWtYU2xgVhdYkUoO8RIJHTqc4NEYTtFjPRAZe1J18oKbmcvaz6VkWjfRMUmihlffTGeRub5qRJeFplgeYJIXD/pYlSAzP674ncvqMA=="/>|' /config/httpSession.xml
fi


if [ -n "$RELEASE_NAME" ]
then
  echo "Prefix decision server console cookie names with $RELEASE_NAME"
        sed -i 's|RELEASE_NAME|'$RELEASE_NAME'|g' /config/httpSession.xml
else
  echo "Prefix decision server console cookie names with $HOSTNAME"
        sed -i 's|RELEASE_NAME|'$HOSTNAME'|g' /config/httpSession.xml
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
