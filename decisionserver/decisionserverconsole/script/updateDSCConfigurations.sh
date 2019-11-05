#!/bin/bash

if [ -n "$DECISION_SERVICE_URL" ]; then
	echo "Update DECISION_SERVICE_URL to $DECISION_SERVICE_URL in Decision Server Console."
	sed -i 's|/DecisionService|'$DECISION_SERVICE_URL'|g' $APPS/res.war/WEB-INF/web.xml
fi

if [ -f "/config/baiemitterconfig/plugin-configuration.properties" ]; then
	echo "Enable BAI Emitter Plugin"
        sed -i 's/{pluginClass=HTDS}/&,{pluginClass=ODMEmitterForBAI}/' ra.xml
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

if [ -s "/config/auth/openIdParameters.txt" ]
then
  echo "replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
  sed -i $'/<group name="resAdministrators"/{e cat /config/authOidc/resAdministrators.xml\n}' /config/application.xml
  sed -i '/<group name="resAdministrators"/d' /config/application.xml
  sed -i $'/<group name="resDeployers"/{e cat /config/authOidc/resDeployers.xml\n}' /config/application.xml
  sed -i '/<group name="rtsDeployers"/d' /config/application.xml
  sed -i $'/<group name="resMonitors"/{e cat /config/authOidc/resMonitors.xml\n}' /config/application.xml
  sed -i '/<group name="resMonitors"/d' /config/application.xml
  sed -i $'/<group name="resExecutors"/{e cat /config/authOidc/resExecutors.xml\n}' /config/application.xml
  sed -i '/<group name="resExecutors"/d' /config/application.xml

  echo "Enable UMS authentication"
  UMS_ALLOWED_DOMAINS=$(grep UMS_ALLOWED_DOMAINS /config/auth/openIdParameters.txt | sed "s/UMS_ALLOWED_DOMAINS=//g")
  echo "UMS_ALLOWED_DOMAINS: $UMS_ALLOWED_DOMAINS"
  UMS_LOGOUT_URL=$(grep UMS_LOGOUT_URL /config/auth/openIdParameters.txt | sed "s/UMS_LOGOUT_URL=//g")
  if [ -n "$UMS_LOGOUT_URL" ]; then
  	echo "UMS_LOGOUT_URL: $UMS_LOGOUT_URL"
	sed -i 's|type=local|'type=openid,logoutUrl=$UMS_LOGOUT_URL'|g' $APPS/res.war/WEB-INF/web.xml
  else
	sed -i 's|type=local|'type=openid'|g' $APPS/res.war/WEB-INF/web.xml
  fi
  sed -i 's|UMS_ALLOWED_DOMAINS|'$UMS_ALLOWED_DOMAINS'|g' /config/oAuth.xml
  sed -i $'/<\/web-app>/{e cat /config/oAuth.xml\n}' $APPS/res.war/WEB-INF/web.xml
else
  echo "No provided /config/auth/openIdParameters.txt"
fi
