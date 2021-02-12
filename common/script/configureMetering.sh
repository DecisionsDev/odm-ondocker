#!/bin/bash

if [ -s "/config/pluginconfig/plugin-configuration.properties" ]
then
	echo "Configure metering using /config/pluginconfig/plugin-configuration.properties provided config"
elif [ -n "$METERING_SERVER_URL" ]
then
	echo "Configure metering using /config/metering-template.properties template"
	echo "Set METERING_SERVER_URL with $METERING_SERVER_URL"
	sed -i 's|METERING_SERVER_URL|'$METERING_SERVER_URL'|g' /config/metering-template.properties
	if [ -n "$RELEASE_NAME" ]
	then
  		echo "Set METERING_INSTANCE_ID with $RELEASE_NAME"
        sed -i 's|METERING_INSTANCE_ID|'$RELEASE_NAME'|g' /config/metering-template.properties
	else
  		echo "Set METERING_INSTANCE_ID with $HOSTNAME"
        sed -i 's|METERING_INSTANCE_ID|'$HOSTNAME'|g' /config/metering-template.properties
	fi

	if [ -n "$METERING_SEND_PERIOD" ]
	then
		echo "Set METERING_SEND_PERIOD with $METERING_SEND_PERIOD milliseconds"
		sed -i 's|METERING_SEND_PERIOD|'$METERING_SEND_PERIOD'|g' /config/metering-template.properties
	else
		echo "Set METERING_SEND_PERIOD with 900000 milliseconds"
		sed -i 's|METERING_SEND_PERIOD|900000|g' /config/metering-template.properties
	fi

	mkdir /config/pluginconfig
	cp /config/metering-template.properties /config/pluginconfig/plugin-configuration.properties
fi
