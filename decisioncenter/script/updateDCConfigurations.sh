#!/bin/bash

echo "Update Decision Center configurations"

FIND_SERVER_EXT_CLASS="$($SCRIPT/findServerExtClass.sh)"
echo "FIND_SERVER_EXT_CLASS set to $FIND_SERVER_EXT_CLASS"

FIND_OAUTH_SERVER_UTIL_CLASS="$($SCRIPT/findOAuthServerUtilClass.sh)"
echo "FIND_OAUTH_SERVER_UTIL_CLASS set to $FIND_OAUTH_SERVER_UTIL_CLASS"

if [ "$FIND_SERVER_EXT_CLASS" == "matches" ]
then
  echo "ServerExt class found then set DC_SERVER_CONFIG to /config/server-configurations.json"
  DC_SERVER_CONFIG="/config/server-configurations.json"
else
  echo "ServerExt class not found. Use old way Decision Center server configuration"
fi

if [ "$FIND_OAUTH_SERVER_UTIL_CLASS" == "matches" ]
then
  echo "OAuthServerUtil class found replace /config/server-configurations.json by /config/new-server-configurations.json"
  mv /config/new-server-configurations.json /config/server-configurations.json
else
  echo "OAuthServerUtil class not found"
fi

if [ -s "/config/openIdParameters.txt" ]
then
  OPENID_SERVER_URL=$(grep OPENID_SERVER_URL /config/openIdParameters.txt | sed "s/OPENID_SERVER_URL=//g")
  echo "OPENID_SERVER_URL: $OPENID_SERVER_URL"
  PROVIDER=$(grep PROVIDER /config/openIdParameters.txt | sed "s/PROVIDER=//g")
  echo "PROVIDER: $PROVIDER"
  echo "OAuth config : change BASIC_AUTH to OAUTH in $DC_SERVER_CONFIG"
  sed -i 's|BASIC_AUTH|'OAUTH'|g' $DC_SERVER_CONFIG
  if [ -n "$PROVIDER" ]
  then
     echo "OAuth config : set provider to $PROVIDER"
     sed -i 's|PROVIDER|'$PROVIDER'|g' $DC_SERVER_CONFIG
     sed -i 's|PROVIDER|'$PROVIDER'|g' /config/new-decisioncenter-configuration.properties
  else
     sed -i 's|"PROVIDER"|'null'|g' $DC_SERVER_CONFIG
  fi
  echo "OAuth config : set AUTH_SCHEME to oidc in /config/new-decisioncenter-configuration.properties"
  echo "OAuth config : set OPENID_SERVER_URL to $OPENID_SERVER_URL in /config/new-decisioncenter-configuration.properties"
  sed -i 's|OPENID_SERVER_URL|'$OPENID_SERVER_URL'|g' /config/new-decisioncenter-configuration.properties 
  echo "replace rtsAdministators/rtsConfigManagers/rtsInstallers group in /config/application.xml"
  sed -i 's|group name="rtsAdministrators"|group name="${odm.rtsAdministrator.group1}"|g' /config/application.xml
  sed -i 's|group name="rtsConfigManagers"|group name="${odm.rtsConfigManager.group1}"|g' /config/application.xml
  sed -i 's|group name="rtsInstallers"|group name="${odm.rtsInstaller.group1}"|g' /config/application.xml
else
  echo "BASIC_AUTH config : remove entry with OPEN_ID_SERVER_URL in /config/new-decisioncenter-configuration.properties"
  sed -i '/OPENID_SERVER_URL/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove entry SCHEME with oidc in /config/new-decisioncenter-configuration.properties"
  sed -i '/scheme=oidc/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove oidc provider entry in /config/new-decisioncenter-configuration.properties"
  sed -i '/OdmOidcProviders/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove authFilters from server.xml"
  sed -i '/authFilters/d' /config/server.xml
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

if [ -s "/config/OdmOidcProviders.json" ]
then
  echo "Copy OdmOidcProviders.json resource to $APPS/decisioncenter.war/WEB-INF/classes/config/OdmOidcProviders.json"
        cp /config/OdmOidcProviders.json $APPS/decisioncenter.war/WEB-INF/classes/OdmOidcProviders.json
        cp /config/OdmOidcProviders.json $APPS/teamserver.war/WEB-INF/classes/OdmOidcProviders.json
        cp /config/OdmOidcProviders.json $APPS/decisioncenter-api.war/WEB-INF/classes/OdmOidcProviders.json
else
  echo "No provided /config/OdmOidcProviders.json"
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

if [ -n "$RELEASE_NAME" ]
then
  echo "Prefix decision center cookie names with $RELEASE_NAME"
        sed -i 's|RELEASE_NAME|'$RELEASE_NAME'|g' /config/httpSession.xml
else
  echo "Prefix decision center cookie names with $HOSTNAME"
        sed -i 's|RELEASE_NAME|'$HOSTNAME'|g' /config/httpSession.xml
fi

if [ -s "/config/customlib/web.xml" ]
then
  echo "Update web.xml for Decision Center customization" 
  PATTERN="<?-- Add your custom servlets here if needed -->"
  CONTENT=$(cat /config/apps/decisioncenter.war/WEB-INF/web.xml)
  REPLACE=$(cat /config/customlib/web.xml)
  outputvar="${CONTENT//$PATTERN/$REPLACE}"
  echo $outputvar > /config/apps/decisioncenter.war/WEB-INF/web.xml
fi

if [ -s "/config/customlib/js" ]
then
  echo "Update javascript for Decision Center customization"
  cp -r /config/customlib/js/* /config/apps/decisioncenter.war/js
fi
