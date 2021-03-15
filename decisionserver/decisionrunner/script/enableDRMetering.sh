#!/bin/bash

if [ -n "$COM_IBM_RULES_METERING_ENABLE" ]
then
	echo "enable rules metering"
	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
	sed -i 's/{pluginClass=DVS}/{pluginClass=Metering,enable=true},{pluginClass=DVS}/g' ra.xml

	$SCRIPT/configureMetering.sh
fi
