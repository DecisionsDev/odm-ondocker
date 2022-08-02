#!/bin/bash

. $SCRIPT/initVariables.sh 9060 9453

if [ -s "$SCRIPT/customStart.sh" ]
then
	$SCRIPT/customStart.sh
fi

$SCRIPT/addDCApplications.sh

$SCRIPT/updateDCConfigurations.sh

if [ -n "$USERS_PASSWORD" ]
then
  echo "Set password for defaut users"
  sed -i 's|password=".*"|'password=\"$USERS_PASSWORD\"'|g' /config/auth/webSecurity.xml
  sed -i 's|"loginPassword": ".*"|'\"loginPassword\":\"$USERS_PASSWORD\"'|g' /config/server-configurations.json
fi

$SCRIPT/updatePersistenceLocale.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/updateDatasource.sh

$SCRIPT/configureSwidTag.sh

$SCRIPT/setTimeZone.sh

. $SCRIPT/setUTF8Locale.sh

$SCRIPT/generateRDFiles.sh

if [ -s "$SCRIPT/customEnd.sh" ]
then
        $SCRIPT/customEnd.sh
fi

if [ -n "$DEMO" ]
then
	$SCRIPT/updateDemoServers.sh &
fi
