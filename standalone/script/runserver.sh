#!/bin/bash
set -e

$SCRIPT/checkLicense.sh

if [ ! -f /config/initializeddb.flag ] ; then
    # if $SAMPLE not exist, or set to true
	if [ -z "$SAMPLE" ] || [ "$SAMPLE" = "true" ] ; then
		if [ -d "/config/dbdata/" ]; then
  			cp -R /upload/* /config/dbdata/
		fi;
	fi;
	touch /config/initializeddb.flag
fi;

if [ ! -f /config/initialized.flag ] ; then
	cd  $APPS/DecisionService.war/WEB-INF/classes;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
	touch /config/initialized.flag
fi;

FIND_SERVER_EXT_CLASS="$($SCRIPT/findServerExtClass.sh)"
echo "FIND_SERVER_EXT_CLASS set to $FIND_SERVER_EXT_CLASS"

if [ "$FIND_SERVER_EXT_CLASS" == "matches" ]
then
  echo "ServerExt class found. Use /config/server-configurations.json server definition"
  cp /config/new-decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
  echo "ServerExt class not found. Use old decisioncenter-configuration.properties server definition"
        cp /config/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

$SCRIPT/enableMetering.sh

$SCRIPT/configureDatabase.sh h2

$SCRIPT/updateDatasource.sh

$SCRIPT/updatePersistenceLocale.sh

$SCRIPT/configureTlsSecurity.sh

$SCRIPT/addDCApplications.sh config/decisioncenter_application.xml

/opt/ibm/wlp/bin/server run defaultServer
