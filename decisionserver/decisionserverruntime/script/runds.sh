#!/bin/bash

. $SCRIPT/initVariables.sh 9080 9443
if [ ! -f /config/initialized ]
then
        if [ -s "$SCRIPT/customStart.sh" ]
        then
          . $SCRIPT/customStart.sh
        fi

        $SCRIPT/download.sh

        if [ -n "$USERS_PASSWORD" ]
        then
        echo "Set password for defaut users"
        sed -i 's|password=".*"|'password=\"$USERS_PASSWORD\"'|g' /config/auth/webSecurity.xml
        fi

        $SCRIPT/enableMetering.sh

        $SCRIPT/updateDSRConfigurations.sh

        $SCRIPT/configureTcpipNotification.sh

        $SCRIPT/configureTlsSecurity.sh

        $SCRIPT/configureDatabase.sh

        $SCRIPT/updateDatasource.sh

        $SCRIPT/configureSwidTag.sh

        $SCRIPT/setTimeZone.sh

        if [ -s "$SCRIPT/customEnd.sh" ]
        then
          . $SCRIPT/customEnd.sh
        fi
        touch /config/initialized
fi
