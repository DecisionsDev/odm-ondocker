#!/bin/bash

$SCRIPT/updateDSCConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureUserRegistry.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/changeDatasource.sh

$SCRIPT/updateDSRConfigurations.sh

$SCRIPT/enableMetering.sh

/opt/ibm/docker/docker-server run defaultServer
