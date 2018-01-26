#!/bin/bash

$SCRIPT/updateDSRConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/enableMetering.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/changeDatasource.sh

/opt/ibm/docker/docker-server run defaultServer
