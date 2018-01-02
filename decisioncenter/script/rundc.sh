#!/bin/bash

$SCRIPT/updateDCConfigurations.sh

$SCRIPT/updatePersistenceLocale.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureUserRegistry.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/changeDatasource.sh

$SCRIPT/addRestApi.sh

$SCRIPT/jvmOptions.sh

/opt/ibm/docker/docker-server run defaultServer
