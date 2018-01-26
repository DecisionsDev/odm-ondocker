#!/bin/bash

$SCRIPT/updateDSCConfigurations.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/changeDatasource.sh

/opt/ibm/docker/docker-server run defaultServer
