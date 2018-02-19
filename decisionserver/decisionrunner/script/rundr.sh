#!/bin/bash

$SCRIPT/updateDRConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/changeDatasource.sh

/opt/ibm/wlp/bin/server run defaultServer
