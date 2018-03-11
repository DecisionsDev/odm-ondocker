#!/bin/bash

$SCRIPT/updateDSCConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/updateDatasource.sh

$SCRIPT/updateDSRConfigurations.sh

$SCRIPT/enableMetering.sh

/opt/ibm/wlp/bin/server run defaultServer
