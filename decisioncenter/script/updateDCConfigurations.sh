#!/bin/bash

echo "Update Decision Center configurations"

FIND_SERVER_EXT_CLASS="$($SCRIPT/findServerExtClass.sh)"
echo "FIND_SERVER_EXT_CLASS set to $FIND_SERVER_EXT_CLASS"

if [ "$FIND_SERVER_EXT_CLASS" == "matches" ]
then
  echo "ServerExt class found then set DC_SERVER_CONFIG to /config/server-configurations.json"
  DC_SERVER_CONFIG="/config/server-configurations.json"
else
  echo "ServerExt class not found. Use old way Decision Center server configuration"
fi

if [ -n "DC_SERVER_CONFIG" ]
then
  echo "DC_SERVER_CONFIG set to $DC_SERVER_CONFIG"
else
  echo "DC_SERVER_CONFIG not set. Use old way Decision Center server configuration" 	
	DC_SERVER_CONFIG="/config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties"
fi

if [ "$DC_SERVER_CONFIG" == "/config/server-configurations.json" ]
then
  echo "Update decisioncenter-configuration.properties with /config/server-configurations.json"
	cp /config/new-decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
  echo "Use old decisioncenter-configuration.properties definition"
	cp /config/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
  echo "Update decision server console name to $DECISIONSERVERCONSOLE_NAME in $DC_SERVER_CONFIG"
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' $DC_SERVER_CONFIG
fi
if [ -n "$DECISIONRUNNER_NAME" ]
then
  echo "Update decision runner name to $DECISIONRUNNER_NAME in $DC_SERVER_CONFIG"
	sed -i 's|odm-decisionrunner|'$DECISIONRUNNER_NAME'|g' $DC_SERVER_CONFIG
fi


if [ -n "$ENABLE_TLS" ]
then
 echo "Update decision server and runner protocol to https in $DC_SERVER_CONFIG"
        sed -i 's|protocol|'https'|g' $DC_SERVER_CONFIG
else
 echo "Update decision server and runner protocol to http in $DC_SERVER_CONFIG"
        sed -i 's|protocol|'http'|g' $DC_SERVER_CONFIG
fi

if [ -n "$DECISIONSERVERCONSOLE_PORT" ]
then
  echo "Update decision server console port to $DECISIONSERVERCONSOLE_PORT in $DC_SERVER_CONFIG"
        sed -i 's|decisionserverconsole-port|'$DECISIONSERVERCONSOLE_PORT'|g' $DC_SERVER_CONFIG
else
  echo "Update decision server console port to default 9080 in $DC_SERVER_CONFIG"
        sed -i 's|decisionserverconsole-port|'9080'|g' $DC_SERVER_CONFIG
fi
if [ -n "$DECISIONRUNNER_PORT" ]
then
  echo "Update decision runner port to $DECISIONRUNNER_PORT in $DC_SERVER_CONFIG"
        sed -i 's|decisionrunner-port|'$DECISIONRUNNER_PORT'|g' $DC_SERVER_CONFIG
else
  echo "Update decision runner port to default 9080 in $DC_SERVER_CONFIG"
        sed -i 's|decisionrunner-port|'9080'|g' $DC_SERVER_CONFIG
fi

if [ -s "/config/auth/ldap-configurations.xml" ] 
then
  echo "Update LDAP synchronization mode to users in decisioncenter-configuration.properties"
  sed -i 's|ldap-sync-mode|'users'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
  sed -i 's|ldap-file|'\/opt\/ibm\/wlp\/usr\/servers\/defaultServer\/auth\/ldap-configurations.xml'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
  echo "Update LDAP synchronization mode to none in decisioncenter-configuration.properties"
  sed -i 's|ldap-sync-mode|'none'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
  sed -i 's|ldap-file|''|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

if [ -s "/config/auth/group-security-configurations.xml" ] 
then
  sed -i 's|group-file|'\/opt\/ibm\/wlp\/usr\/servers\/defaultServer\/auth\/group-security-configurations.xml'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
else
  sed -i 's|group-file|''|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi
