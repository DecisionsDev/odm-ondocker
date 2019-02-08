#!/bin/bash

$SCRIPT/updateDRConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/updateDatasource.sh

$SCRIPT/configureSwidTag.sh

/opt/ibm/wlp/bin/server run defaultServer
