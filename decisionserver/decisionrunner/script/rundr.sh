#!/bin/bash

. $SCRIPT/initVariables.sh 9080 9443

$SCRIPT/updateDRConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/enableDRMetering.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/updateDatasource.sh

$SCRIPT/configureSwidTag.sh

$SCRIPT/setTimeZone.sh

/opt/ibm/wlp/bin/server run defaultServer
