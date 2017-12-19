#!/bin/bash

$SCRIPT/updateDRConfiguration.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureUserRegistry.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/changeDatasource.sh

/opt/ibm/docker/docker-server run defaultServer
