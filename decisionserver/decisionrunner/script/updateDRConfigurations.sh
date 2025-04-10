#!/bin/bash

echo "Update Decision Runner configurations"

if [ ! -f /config/initialized.flag ] ; then
	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
        if [ -n "$CONNECTION_POOL_TIMEOUT" ]
        then
		echo "Configure XU connection pool size to $CONNECTION_POOL_SIZE and XU connection pool timeout to $CONNECTION_POOL_TIMEOUT"
		sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value>.*|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout='$CONNECTION_POOL_TIMEOUT'</config-property-value>|' ra.xml;
        else
		echo "Configure XU connection pool size to $CONNECTION_POOL_SIZE and XU connection pool timeout to default value 3000"
                sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value>.*|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	fi
        if [ -n "$RES_URL" ]
        then
                echo "Configure RES_URL with provided $RES_URL"
		sed -i '/<param-name>RES_URL<\/param-name>/{n;s/<param-value\/>/<param-value>res-url-to-replace<\/param-value>/;}' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
		sed -i 's|res-url-to-replace|'$RES_URL'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
        else
                sed -i '/<param-name>RES_URL<\/param-name>/{n;s/<param-value\/>/<param-value>protocol:\/\/odm-decisionserverconsole:decisionserverconsole-portdecisionserverconsole-context-root\/res<\/param-value>/;}' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
                if [ -n "$DECISIONSERVERCONSOLE_CONTEXT_ROOT" ]
                then
		     echo "Configure decisionserverconsole-context-root to $DECISIONSERVERCONSOLE_CONTEXT_ROOT in /config/apps/DecisionRunner.war/WEB-INF/web.xml"
		     sed -i 's|decisionserverconsole-context-root|'$DECISIONSERVERCONSOLE_CONTEXT_ROOT'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
	        else
		     echo "No DECISIONSERVERCONSOLE_CONTEXT_ROOT set"
                     sed -i 's|decisionserverconsole-context-root|''|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
	        fi
        fi
	touch /config/initialized.flag
fi;


if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/DecisionRunner.war/WEB-INF/classes/ra.xml;
	if [ ! -n "$RES_URL" ]
        then
           echo "Configure DECISIONSERVERCONSOLE_NAME to $DECISIONSERVERCONSOLE_NAME in /config/apps/DecisionRunner.war/WEB-INF/web.xml"
	   sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
	fi
fi

if [ ! -n "$RES_URL" ]
        then
	if [ -n "$ENABLE_TLS" ]
	then
 	echo "Update decision server protocol to https in web.xml"
	        sed -i 's|protocol|'https'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
	else
	 echo "Update decision server protocol to http in web.xml"
	        sed -i 's|protocol|'http'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
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

if [ ! -n "$RES_URL" ]
        then
	if [ -n "$DECISIONSERVERCONSOLE_PORT" ]
	then
  	echo "Update decision server console port to $DECISIONSERVERCONSOLE_PORT in web.xml"
	        sed -i 's|decisionserverconsole-port|'$DECISIONSERVERCONSOLE_PORT'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
	else
		echo "Update decision server console port to default 9080 in web.xml"
	        sed -i 's|decisionserverconsole-port|'9080'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
	fi
fi

if [ -n "$RELEASE_NAME" ]
then
  echo "Prefix decision server console cookie names with $RELEASE_NAME"
        sed -i 's|RELEASE_NAME|'$RELEASE_NAME'|g' /config/httpSession.xml
else
  echo "Prefix decision server console cookie names with $HOSTNAME"
        sed -i 's|RELEASE_NAME|'$HOSTNAME'|g' /config/httpSession.xml
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
  sed -i $'/<group name="resAdministrators"/{e cat /config/authOidc/resAdministrators.xml\n}' /config/application.xml
  sed -i '/<group name="resAdministrators"/d' /config/application.xml
  sed -i $'/<group name="resDeployers"/{e cat /config/authOidc/resDeployers.xml\n}' /config/application.xml
  sed -i '/<group name="rtsDeployers"/d' /config/application.xml
else
  echo "No provided /config/authOidc/openIdParameters.properties"
  echo "BASIC_AUTH config : remove authFilters from server.xml"
  sed -i '/authFilters/d' /config/server.xml
  echo "BASIC_AUTH config : remove openIdWebSecurity from server.xml"
  sed -i '/openIdWebSecurity/d' /config/server.xml
  echo "BASIC_AUTH config : remove oidcClientWebapp from server.xml"
  sed -i '/oidcClientWebapp/d' /config/server.xml

  if [ -n "$DR_ROLE_GROUP_MAPPING" ]
  then
    echo "DR_ROLE_GROUP_MAPPING set then replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
    sed -i $'/<group name="resAdministrators"/{e cat /config/authOidc/resAdministrators.xml\n}' /config/application.xml
    sed -i '/<group name="resAdministrators"/d' /config/application.xml
    sed -i $'/<group name="resDeployers"/{e cat /config/authOidc/resDeployers.xml\n}' /config/application.xml
    sed -i '/<group name="rtsDeployers"/d' /config/application.xml
  fi
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
