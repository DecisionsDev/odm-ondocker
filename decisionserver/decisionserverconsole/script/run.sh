#!/bin/bash

. $SCRIPT/initVariables.sh 9080 9443

if [ -s "$SCRIPT/customStart.sh" ]
then
        $SCRIPT/customStart.sh
fi

$SCRIPT/enableMetering.sh

$SCRIPT/updateDSCConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/updateDatasource.sh

$SCRIPT/configureSwidTag.sh

$SCRIPT/setTimeZone.sh

if [ -s "$SCRIPT/customEnd.sh" ]
then
        $SCRIPT/customEnd.sh
fi

/opt/ibm/wlp/bin/server run defaultServer
