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

if [ -s "/config/openIdParameters.txt" ]
then
echo "replace resAdministators/resConfigManagers/resInstallers/resExecutors group in /config/application.xml"
  sed -i 's|group name="resAdministrators"|group name="${odm.resAdministrators.group1}"|g' /config/application.xml
  sed -i 's|group name="resDeployers"|group name="${odm.resDeployers.group1}"|g' /config/application.xml
  sed -i 's|group name="resMonitors"|group name="${odm.resMonitors.group1}"|g' /config/application.xml
  sed -i 's|group name="resExecutors"|group name="${odm.resExecutors.group1}"|g' /config/application.xml
fi
