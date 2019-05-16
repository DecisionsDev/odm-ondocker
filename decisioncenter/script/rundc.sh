#!/bin/bash

$SCRIPT/updateDCConfigurations.sh

$SCRIPT/updatePersistenceLocale.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/configureDatabase.sh

$SCRIPT/updateDatasource.sh

$SCRIPT/addDCApplications.sh

$SCRIPT/configureSwidTag.sh

$SCRIPT/jvmOptions.sh

$SCRIPT/setTimeZone.sh

. $SCRIPT/setUTF8Locale.sh

/opt/ibm/wlp/bin/server run defaultServer
