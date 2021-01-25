#!/bin/bash

if [ -n "$COM_IBM_RULES_METERING_ENABLE" ]
then
	echo "enable rules metering"
	cd  /config/apps/DecisionService.war/WEB-INF/classes;
	sed -i 's/{pluginClass=HTDS}/{pluginClass=Metering,enable=true},{pluginClass=HTDS}/g' ra.xml

	if [ -n "$METERING_SERVER_URL" ]
	then
		if [ -s "/config/pluginconfig/plugin-configuration.properties" ]
		then 
			echo "Configure metering using /config/pluginconfig/plugin-configuration.properties provided config"
		else
			echo "Configure metering using /config/metering-template.properties template"
			sed -i 's|METERING_SERVER_URL|'$METERING_SERVER_URL'|g' /config/metering-template.properties
			if [ -n "$RELEASE_NAME" ]
			then
  				echo "Set METERING_INSTANCE_ID with $RELEASE_NAME"
        			sed -i 's|METERING_INSTANCE_ID|'$RELEASE_NAME'|g' /config/metering-template.properties
			else
  				echo "Set METERING_INSTANCE_ID with $HOSTNAME"
        			sed -i 's|METERING_INSTANCE_ID|'$HOSTNAME'|g' /config/metering-template.properties
			fi
			mkdir /config/pluginconfig
			cp /config/metering-template.properties /config/pluginconfig/plugin-configuration.properties
		fi
        fi
fi
