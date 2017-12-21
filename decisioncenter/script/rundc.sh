#!/bin/bash

$SCRIPT/updateDCConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureUserRegistry.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/changeDatasource.sh

$SCRIPT/addRestApi.sh

/opt/ibm/docker/docker-server run defaultServer
