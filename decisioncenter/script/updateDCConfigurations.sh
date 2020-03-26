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

if [ -n "$OPENID_CONFIG" ]
then
  if [ -s "/config/auth/openIdParameters.properties" ]
  then
    echo "copy provided /config/auth/openIdParameters.properties to /config/authOidc/openIdParameters.properties"
    cp /config/auth/openIdParameters.properties /config/authOidc/openIdParameters.properties
  else
    echo "copy template to /config/authOidc/openIdParameters.properties"
    mv /config/authOidc/openIdParametersTemplate.properties /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_SERVER_URL__|'$OPENID_SERVER_URL'|g' /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_PROVIDER__|'$OPENID_PROVIDER'|g' /config/authOidc/openIdParameters.properties
    sed -i 's|__OPENID_ALLOWED_DOMAINS__|'$OPENID_ALLOWED_DOMAINS'|g' /config/authOidc/openIdParameters.properties
  fi
  sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/authOidc/openIdParameters.properties
  sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/authOidc/openIdParameters.properties

if [ -s "/config/auth/openIdWebSecurity.xml" ]
  then
    echo "copy provided /config/auth/openIdWebSecurity.xml to /config/authOidc/openIdWebSecurity.xml"
    cp /config/auth/openIdWebSecurity.xml /config/authOidc/openIdWebSecurity.xml
  else
    echo "copy template to /config/authOidc/openIdWebSecurity.xml"
    mv /config/authOidc/openIdWebSecurityTemplate.xml /config/authOidc/openIdWebSecurity.xml
    sed -i 's|__OPENID_SERVER_URL__|'$OPENID_SERVER_URL'|g' /config/authOidc/openIdWebSecurity.xml
    sed -i 's|__OPENID_PROVIDER__|'$OPENID_PROVIDER'|g' /config/authOidc/openIdWebSecurity.xml
  fi
  sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/authOidc/openIdWebSecurity.xml
  sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/authOidc/openIdWebSecurity.xml
fi

if [ -s "/config/authOidc/openIdParameters.properties" ]
then
  OPENID_SERVER_URL=$(grep OPENID_SERVER_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_SERVER_URL=//g")
  echo "OPENID_SERVER_URL: $OPENID_SERVER_URL"
  OPENID_PROVIDER=$(grep OPENID_PROVIDER /config/authOidc/openIdParameters.properties | sed "s/OPENID_PROVIDER=//g")
  echo "OPENID_PROVIDER: $OPENID_PROVIDER"
  echo "OAuth config : change BASIC_AUTH to OAUTH in $DC_SERVER_CONFIG"
  sed -i 's|BASIC_AUTH|'OAUTH'|g' $DC_SERVER_CONFIG
  if [ -n "$OPENID_PROVIDER" ]
  then
     echo "OAuth config : set provider to $OPENID_PROVIDER"
     sed -i 's|OPENID_PROVIDER|'$OPENID_PROVIDER'|g' $DC_SERVER_CONFIG
     sed -i 's|OPENID_PROVIDER|'$OPENID_PROVIDER'|g' /config/new-decisioncenter-configuration.properties

     sed -i 's|OPENID_PROVIDER|'$OPENID_PROVIDER'|g' /config/OdmOidcProviders.json
     
     OPENID_AUTHORIZATION_URL=$(grep OPENID_AUTHORIZATION_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_AUTHORIZATION_URL=//g")
     echo "OAuth config : set authorization URL to $OPENID_AUTHORIZATION_URL"
     sed -i 's|OPENID_AUTHORIZATION_URL|'$OPENID_AUTHORIZATION_URL'|g' /config/OdmOidcProviders.json
     
     OPENID_TOKEN_URL=$(grep OPENID_TOKEN_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_TOKEN_URL=//g")
     echo "OAuth config : set token URL to $OPENID_TOKEN_URL"
     sed -i 's|OPENID_TOKEN_URL|'$OPENID_TOKEN_URL'|g' /config/OdmOidcProviders.json

     OPENID_INTROSPECTION_URL=$(grep OPENID_INTROSPECTION_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_INTROSPECTION_URL=//g")
     echo "OAuth config : set introspection URL to $OPENID_INTROSPECTION_URL"
     sed -i 's|OPENID_INTROSPECTION_URL|'$OPENID_INTROSPECTION_URL'|g' /config/OdmOidcProviders.json

     OPENID_CLIENT_ID=$(grep OPENID_CLIENT_ID /config/authOidc/openIdParameters.properties | sed "s/OPENID_CLIENT_ID=//g")
     echo "OAuth config : set client ID to $OPENID_CLIENT_ID"
     sed -i 's|OPENID_CLIENT_ID|'$OPENID_CLIENT_ID'|g' /config/OdmOidcProviders.json

     OPENID_CLIENT_SECRET=$(grep OPENID_CLIENT_SECRET /config/authOidc/openIdParameters.properties | sed "s/OPENID_CLIENT_SECRET=//g")
     echo "OAuth config : set client Secret to $OPENID_CLIENT_SECRET"
     sed -i 's|OPENID_CLIENT_SECRET|'$OPENID_CLIENT_SECRET'|g' /config/OdmOidcProviders.json

     OPENID_TOKEN_FORMAT=$(grep OPENID_TOKEN_FORMAT /config/authOidc/openIdParameters.properties | sed "s/OPENID_TOKEN_FORMAT=//g")
     echo "OAuth config : set Token Format to $OPENID_TOKEN_FORMAT"
     sed -i 's|OPENID_TOKEN_FORMAT|'$OPENID_TOKEN_FORMAT'|g' /config/OdmOidcProviders.json
     
     echo "Copy /config/OdmOidcProviders.json resource to $APPS/decisioncenter.war/WEB-INF/classes/config/OdmOidcProviders.json"
     cp /config/OdmOidcProviders.json $APPS/decisioncenter.war/WEB-INF/classes/OdmOidcProviders.json
     cp /config/OdmOidcProviders.json $APPS/teamserver.war/WEB-INF/classes/OdmOidcProviders.json
     cp /config/OdmOidcProviders.json $APPS/decisioncenter-api.war/WEB-INF/classes/OdmOidcProviders.json
  else
     sed -i 's|"OPENID_PROVIDER"|'null'|g' $DC_SERVER_CONFIG
  fi
  echo "OAuth config : set AUTH_SCHEME to oidc in /config/new-decisioncenter-configuration.properties"
  echo "OAuth config : set OPENID_SERVER_URL to $OPENID_SERVER_URL in /config/new-decisioncenter-configuration.properties"
  sed -i 's|OPENID_SERVER_URL|'$OPENID_SERVER_URL'|g' /config/new-decisioncenter-configuration.properties 
  echo "replace rtsAdministators/rtsConfigManagers/rtsInstallers group in /config/application.xml"
  sed -i $'/<group name="rtsAdministrators"/{e cat /config/authOidc/rtsAdministrators.xml\n}' /config/application.xml
  sed -i '/<group name="rtsAdministrators"/d' /config/application.xml
  sed -i $'/<group name="rtsInstallers"/{e cat /config/authOidc/rtsInstallers.xml\n}' /config/application.xml
  sed -i '/<group name="rtsInstallers"/d' /config/application.xml
  sed -i $'/<group name="rtsConfigManagers"/{e cat /config/authOidc/rtsConfigManagers.xml\n}' /config/application.xml
  sed -i '/<group name="rtsConfigManagers"/d' /config/application.xml

else
  echo "No provided /config/authOidc/openIdParameters.properties"
  echo "BASIC_AUTH config : set provider to null in $DC_SERVER_CONFIG"
  sed -i 's|"OPENID_PROVIDER"|'null'|g' $DC_SERVER_CONFIG
  echo "BASIC_AUTH config : remove entry with OPEN_ID_SERVER_URL in /config/new-decisioncenter-configuration.properties"
  sed -i '/OPENID_SERVER_URL/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove entry SCHEME with oidc in /config/new-decisioncenter-configuration.properties"
  sed -i '/scheme=oidc/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove oidc provider entry in /config/new-decisioncenter-configuration.properties"
  sed -i '/OdmOidcProviders/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove authFilters from server.xml"
  sed -i '/authFilters/d' /config/server.xml
  echo "BASIC_AUTH config : remove openIdWebSecurity from server.xml"
  sed -i '/openIdWebSecurity/d' /config/server.xml

  if [ -n "$DC_ROLE_GROUP_MAPPING" ]
  then
    echo "DC_ROLE_GROUP_MAPPING set then replace rtsAdministators/rtsConfigManagers/rtsInstallers group in /config/application.xml"
    sed -i $'/<group name="rtsAdministrators"/{e cat /config/authOidc/rtsAdministrators.xml\n}' /config/application.xml
    sed -i '/<group name="rtsAdministrators"/d' /config/application.xml
    sed -i $'/<group name="rtsInstallers"/{e cat /config/authOidc/rtsInstallers.xml\n}' /config/application.xml
    sed -i '/<group name="rtsInstallers"/d' /config/application.xml
    sed -i $'/<group name="rtsConfigManagers"/{e cat /config/authOidc/rtsConfigManagers.xml\n}' /config/application.xml
    sed -i '/<group name="rtsConfigManagers"/d' /config/application.xml
  fi
fi

if [ -n "$DC_SERVER_CONFIG" ]
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

if [ -n "$ENABLE_TLS" ]
then
 echo "Use httpSession settings for HTTPS"
 cp /config/httpSessionHttps.xml /config/httpSession.xml
else
 echo "Use httpSession settings for HTTP"
 cp /config/httpSessionHttp.xml /config/httpSession.xml
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
