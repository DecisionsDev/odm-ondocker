#!/bin/bash

echo "Update Decision Runner configurations"

if [ ! -f /config/initialized.flag ] ; then
	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>[D|d]efaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
    sed -i 's|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin}|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin},{pluginClass=Metering}|g' ra.xml;
    sed -i '/<param-name>RES_URL<\/param-name>/{n;s/<param-value\/>/<param-value>protocol:\/\/odm-decisionserverconsole:decisionserverconsole-port\/res<\/param-value>/;}' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
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

if [ -n "$ENABLE_TLS" ]
then
 echo "Use httpSession settings for HTTPS"
 cp /config/httpSessionHttps.xml /config/httpSession.xml
else
 echo "Use httpSession settings for HTTP"
 cp /config/httpSessionHttp.xml /config/httpSession.xml
fi

if [ -n "$DECISIONSERVERCONSOLE_PORT" ]
then
  echo "Update decision server console port to $DECISIONSERVERCONSOLE_PORT in web.xml"
        sed -i 's|decisionserverconsole-port|'$DECISIONSERVERCONSOLE_PORT'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
else
  echo "Update decision server console port to default 9080 in web.xml"
        sed -i 's|decisionserverconsole-port|'9080'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml
fi

if [ -n "$RELEASE_NAME" ]
then
  echo "Prefix decision server console cookie names with $RELEASE_NAME"
        sed -i 's|RELEASE_NAME|'$RELEASE_NAME'|g' /config/httpSession.xml
else
  echo "Prefix decision server console cookie names with $HOSTNAME"
        sed -i 's|RELEASE_NAME|'$HOSTNAME'|g' /config/httpSession.xml
fi

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
  sed -i $'/<group name="resAdministrators"/{e cat /config/authOidc/resAdministrators.xml\n}' /config/application.xml
  sed -i '/<group name="resAdministrators"/d' /config/application.xml
  sed -i $'/<group name="resDeployers"/{e cat /config/authOidc/resDeployers.xml\n}' /config/application.xml
  sed -i '/<group name="rtsDeployers"/d' /config/application.xml
else
  echo "No provided /config/auth/openIdParameters.properties"
  echo "BASIC_AUTH config : remove authFilters from server.xml"
  sed -i '/authFilters/d' /config/server.xml
  echo "BASIC_AUTH config : remove openIdWebSecurity from server.xml"
  sed -i '/openIdWebSecurity/d' /config/server.xml
fi
