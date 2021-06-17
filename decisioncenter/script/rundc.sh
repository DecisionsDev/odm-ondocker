#!/bin/bash

. $SCRIPT/initVariables.sh 9060 9453

if [ -s "$SCRIPT/customStart.sh" ]
then
	$SCRIPT/customStart.sh
fi

$SCRIPT/addDCApplications.sh

$SCRIPT/updateDCConfigurations.sh

$SCRIPT/updatePersistenceLocale.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/updateDatasource.sh

$SCRIPT/configureSwidTag.sh

$SCRIPT/setTimeZone.sh

. $SCRIPT/setUTF8Locale.sh

if [ -s "$SCRIPT/customEnd.sh" ]
then
        $SCRIPT/customEnd.sh
fi

if [ -n "$DEMO" ]
then
	$SCRIPT/updateDemoServers.sh &
fi

