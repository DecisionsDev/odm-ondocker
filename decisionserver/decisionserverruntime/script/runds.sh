#!/bin/bash

"$SCRIPT"/updateDSRConfigurations.sh

"$SCRIPT"/configureTcpipNotification.sh

"$SCRIPT"/configureTlsSecurity.sh

"$SCRIPT"/enableMetering.sh

"$SCRIPT"/configureDatabase.sh

"$SCRIPT"/updateDatasource.sh

"$SCRIPT"/configureSwidTag.sh

"$SCRIPT"/setTimeZone.sh

/opt/ibm/wlp/bin/server run defaultServer
