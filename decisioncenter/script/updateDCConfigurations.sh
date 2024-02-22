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
  if [ -n "$DISABLE_LOGIN_PANEL" ]
  then
    echo "disable Business Console Basic Auth Login Panel"
    echo "<%response.sendRedirect(\"/decisioncenter\");%>" > /config/apps/decisioncenter.war/WEB-INF/views/login.jsp
  fi

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

    if [ -n "$OPENID_TOKEN_FORMAT" ]
    then
      sed -i 's|__OPENID_TOKEN_FORMAT__|'$OPENID_TOKEN_FORMAT'|g' /config/authOidc/openIdParameters.properties
    else
      sed -i '/OPENID_TOKEN_FORMAT/d'  /config/authOidc/openIdParameters.properties
    fi

    if [ -n "$OPENID_GRANT_TYPE" ]
    then
      sed -i 's|__OPENID_GRANT_TYPE__|'$OPENID_GRANT_TYPE'|g' /config/authOidc/openIdParameters.properties
    else
      sed -i '/OPENID_GRANT_TYPE/d' /config/authOidc/openIdParameters.properties
    fi

    if [ -n "$OPENID_LOGOUT_TOKEN_PARAM" ]
    then
      sed -i 's|__OPENID_LOGOUT_TOKEN_PARAM__|'$OPENID_LOGOUT_TOKEN_PARAM'|g' /config/authOidc/openIdParameters.properties
    else
      sed -i '/OPENID_LOGOUT_TOKEN_PARAM/d'  /config/authOidc/openIdParameters.properties
    fi
  fi
  # Set env var if secrets are passed using mounted volumes
  [ -f /config/secrets/oidc-config/clientId ] && export OPENID_CLIENT_ID=$(cat /config/secrets/oidc-config/clientId)
  sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/authOidc/openIdParameters.properties

  if [ -n "$OPENID_MODE" ]
  then
    sed -i '/__OPENID_CLIENT_SECRET__/d' /config/authOidc/openIdParameters.properties
  else
    [ -f /config/secrets/oidc-config/clientSecret ] && export OPENID_CLIENT_SECRET=$(cat /config/secrets/oidc-config/clientSecret)
    sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/authOidc/openIdParameters.properties
  fi

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
  # Set env var if secrets are passed using mounted volumes
  [ -f /config/secrets/oidc-config/clientId ] && export OPENID_CLIENT_ID=$(cat /config/secrets/oidc-config/clientId)
  [ -f /config/secrets/oidc-config/clientSecret ] && export OPENID_CLIENT_SECRET=$(cat /config/secrets/oidc-config/clientSecret)
  sed -i 's|__OPENID_CLIENT_ID__|'$OPENID_CLIENT_ID'|g' /config/authOidc/openIdWebSecurity.xml

  if [ -n "$OPENID_MODE" ]
  then

    if [ "$OPENID_MODE" == "PKCE" ]
    then
      sed -i 's|clientSecret=\"__OPENID_CLIENT_SECRET__\"|pkceCodeChallengeMethod=\"S256\"|g' /config/authOidc/openIdWebSecurity.xml
    fi

    if [ "$OPENID_MODE" == "PRIVATE_KEY_JWT" ]
    then
      sed -i 's|clientSecret=\"__OPENID_CLIENT_SECRET__\"|'tokenEndpointAuthMethod=\"private_key_jwt\" keyAliasName=\"$OPENID_KEYALIAS_NAME\" sslRef=\"odmDefaultSSLConfig\"'|g' /config/authOidc/openIdWebSecurity.xml
    fi
  else
    sed -i 's|__OPENID_CLIENT_SECRET__|'$OPENID_CLIENT_SECRET'|g' /config/authOidc/openIdWebSecurity.xml
  fi
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
     if [ -n "$OPENID_AUTHORIZATION_URL" ]
     then
     	echo "OAuth config : set authorization URL to $OPENID_AUTHORIZATION_URL"
     	sed -i 's|OPENID_AUTHORIZATION_URL|'$OPENID_AUTHORIZATION_URL'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_AUTHORIZATION_URL"
        sed -i '/authorizationURL/d' /config/OdmOidcProviders.json
     fi

     OPENID_TOKEN_URL=$(grep OPENID_TOKEN_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_TOKEN_URL=//g")
     if [ -n "$OPENID_TOKEN_URL" ]
     then
     	echo "OAuth config : set token URL to $OPENID_TOKEN_URL"
     	sed -i 's|OPENID_TOKEN_URL|'$OPENID_TOKEN_URL'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_TOKEN_URL"
        sed -i '/tokenURL/d' /config/OdmOidcProviders.json
     fi

     OPENID_INTROSPECTION_URL=$(grep OPENID_INTROSPECTION_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_INTROSPECTION_URL=//g")
     if [ -n "$OPENID_INTROSPECTION_URL" ]
     then
     	echo "OAuth config : set introspection URL to $OPENID_INTROSPECTION_URL"
     	sed -i 's|OPENID_INTROSPECTION_URL|'$OPENID_INTROSPECTION_URL'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_INTROSPECTION_URL"
        sed -i '/introspectionURL/d' /config/OdmOidcProviders.json
     fi

     OPENID_CLIENT_ID=$(grep OPENID_CLIENT_ID /config/authOidc/openIdParameters.properties | sed "s/OPENID_CLIENT_ID=//g")
     if [ -n "$OPENID_CLIENT_ID" ]
     then
     	echo "OAuth config : set client ID to $OPENID_CLIENT_ID"
     	sed -i 's|OPENID_CLIENT_ID|'$OPENID_CLIENT_ID'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_CLIENT_ID"
        sed -i '/clientId/d' /config/OdmOidcProviders.json
     fi

     OPENID_CLIENT_SECRET=$(grep OPENID_CLIENT_SECRET /config/authOidc/openIdParameters.properties | sed "s/OPENID_CLIENT_SECRET=//g")
     if [ -n "$OPENID_CLIENT_SECRET" ]
     then
     	echo "OAuth config : set client Secret to $OPENID_CLIENT_SECRET"
     	sed -i 's|OPENID_CLIENT_SECRET|'$OPENID_CLIENT_SECRET'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_CLIENT_SECRET"
        sed -i '/clientSecret/d' /config/OdmOidcProviders.json
     fi

     OPENID_CLIENT_ASSERTION_ALIAS_NAME=$(grep OPENID_CLIENT_ASSERTION_ALIAS_NAME /config/authOidc/openIdParameters.properties | sed "s/OPENID_CLIENT_ASSERTION_ALIAS_NAME=//g")
     if [ -n "$OPENID_CLIENT_ASSERTION_ALIAS_NAME" ]
     then
        echo "OAuth config : set client Assertion Alias Name to $OPENID_CLIENT_ASSERTION_ALIAS_NAME"
        sed -i 's|OPENID_CLIENT_ASSERTION_ALIAS_NAME|'$OPENID_CLIENT_ASSERTION_ALIAS_NAME'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_CLIENT_SECRET"
        sed -i '/clientAssertionAliasName/d' /config/OdmOidcProviders.json
     fi

     OPENID_TOKEN_FORMAT=$(grep OPENID_TOKEN_FORMAT /config/authOidc/openIdParameters.properties | sed "s/OPENID_TOKEN_FORMAT=//g")
     if [ -n "$OPENID_TOKEN_FORMAT" ]
     then
	echo "OAuth config : set Token Format to $OPENID_TOKEN_FORMAT"
	sed -i 's|OPENID_TOKEN_FORMAT|'$OPENID_TOKEN_FORMAT'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_TOKEN_FORMAT"
        sed -i '/tokenFormat/d' /config/OdmOidcProviders.json
     fi

     OPENID_LOGOUT_URL=$(grep OPENID_LOGOUT_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_LOGOUT_URL=//g")
     if [ -n "$OPENID_LOGOUT_URL" ]
     then
     	echo "OAuth config : set logout URL to $OPENID_LOGOUT_URL"
     	sed -i 's|OPENID_LOGOUT_URL|'$OPENID_LOGOUT_URL'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_LOGOUT_URL"
        sed -i '/logoutURL/d' /config/OdmOidcProviders.json
     fi

     OPENID_LOGOUT_TOKEN_PARAM=$(grep OPENID_LOGOUT_TOKEN_PARAM /config/authOidc/openIdParameters.properties | sed "s/OPENID_LOGOUT_TOKEN_PARAM=//g")
     if [ -n "$OPENID_LOGOUT_TOKEN_PARAM" ]
     then
        echo "OAuth config : set logout URL to $OPENID_LOGOUT_TOKEN_PARAM"
        sed -i 's|OPENID_LOGOUT_TOKEN_PARAM|'$OPENID_LOGOUT_TOKEN_PARAM'|g' /config/OdmOidcProviders.json
     else
        echo "OAuth config : no provided OPENID_LOGOUT_TOKEN_PARAM"
        sed -i '/logoutTokenParam/d' /config/OdmOidcProviders.json
     fi

     OPENID_GRANT_TYPE=$(grep OPENID_GRANT_TYPE /config/authOidc/openIdParameters.properties | sed "s/OPENID_GRANT_TYPE=//g")
     if [ -n "$OPENID_GRANT_TYPE" ]
     then
	echo "OAuth config : set grantType to $OPENID_GRANT_TYPE"
     	sed -i 's|OPENID_GRANT_TYPE|'$OPENID_GRANT_TYPE'|g' /config/OdmOidcProviders.json
     else
	echo "OAuth config : no provided OPENID_GRANT_TYPE then set default grantType to client_credentials "
	sed -i 's|OPENID_GRANT_TYPE|client_credentials|g' /config/OdmOidcProviders.json
     fi

     echo "Copy /config/OdmOidcProviders.json resource to $APPS/decisioncenter.war/WEB-INF/classes/OdmOidcProviders.json"
     cp /config/OdmOidcProviders.json $APPS/decisioncenter.war/WEB-INF/classes/OdmOidcProviders.json
     cp /config/OdmOidcProviders.json $APPS/decisioncenter-api.war/WEB-INF/classes/OdmOidcProviders.json
  else
     sed -i 's|"OPENID_PROVIDER"|'null'|g' $DC_SERVER_CONFIG
  fi
  echo "OAuth config : set AUTH_SCHEME to oidc in /config/new-decisioncenter-configuration.properties"


  if [ -n "$DC_REFERER_LIST" ]
  then
	echo "OAuth config : provided DC_REFERER_LIST"
  else
	echo "OAuth config : build DC_REFERER_LIST"
  	IFS=','
  	DC_REFERER_LIST=""
  	ALLOWED_DOMAINS_LIST=$(grep OPENID_ALLOWED_DOMAINS /config/authOidc/openIdParameters.properties | sed "s/OPENID_ALLOWED_DOMAINS=//g")
  	read -ra ADDR <<< "${ALLOWED_DOMAINS_LIST}"
  	declare -i j=1
  	for i in "${ADDR[@]}"; do
  	DC_REFERER_LIST=${DC_REFERER_LIST}"https://"$i"/*"
    	  if ((j < "${#ADDR[@]}")); then
      	    DC_REFERER_LIST=${DC_REFERER_LIST}"__COMMA__"
      	    j=j+1
    	fi
  	done
  fi

  echo "OAuth config : set DC_REFERER_LIST to $DC_REFERER_LIST in /config/new-decisioncenter-configuration.properties"
  sed -i 's|DC_REFERER_LIST|'$DC_REFERER_LIST'|g' /config/new-decisioncenter-configuration.properties
  # Issue with DC_REFERER_LIST when built with a comma
  sed -i 's/__COMMA__/,/g' /config/new-decisioncenter-configuration.properties

  echo "replace rtsAdministators/rtsConfigManagers/rtsInstallers group in /config/application.xml"
  sed -i $'/<group name="rtsAdministrators"/{e cat /config/authOidc/rtsAdministrators.xml\n}' /config/application.xml
  sed -i '/<group name="rtsAdministrators"/d' /config/application.xml
  sed -i $'/<group name="rtsInstallers"/{e cat /config/authOidc/rtsInstallers.xml\n}' /config/application.xml
  sed -i '/<group name="rtsInstallers"/d' /config/application.xml
  sed -i $'/<group name="rtsConfigManagers"/{e cat /config/authOidc/rtsConfigManagers.xml\n}' /config/application.xml
  sed -i '/<group name="rtsConfigManagers"/d' /config/application.xml

  if [ -n "$DISABLE_ALL_AUTHENTICATED_RTSUSER" ]
  then
    echo "replace ALL_AUTHENTICATED_USERS by rtsUsers group  in /config/application.xml"
    sed -i $'/<special-subject type=/{e cat /config/authOidc/rtsUsers.xml\n}' /config/application.xml
    sed -i '/<special-subject type=/d' /config/application.xml
  fi

else
  echo "No provided /config/authOidc/openIdParameters.properties"
  echo "BASIC_AUTH config : set provider to null in $DC_SERVER_CONFIG"
  sed -i 's|"OPENID_PROVIDER"|'null'|g' $DC_SERVER_CONFIG

  if [ -n "$DC_REFERER_LIST" ]
  then
        echo "BASIC_AUTH config : provided DC_REFERER_LIST"
	sed -i 's|DC_REFERER_LIST|'$DC_REFERER_LIST'|g' /config/new-decisioncenter-configuration.properties
  else
  	echo "BASIC_AUTH config : remove entry with DC_REFERER_LIST in /config/new-decisioncenter-configuration.properties"
  	sed -i '/DC_REFERER_LIST/d' /config/new-decisioncenter-configuration.properties
  fi

  echo "BASIC_AUTH config : remove entry SCHEME with oidc in /config/new-decisioncenter-configuration.properties"
  sed -i '/scheme=oidc/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove oidc provider entry in /config/new-decisioncenter-configuration.properties"
  sed -i '/OdmOidcProviders/d' /config/new-decisioncenter-configuration.properties
  echo "BASIC_AUTH config : remove authFilters from server.xml"
  sed -i '/authFilters/d' /config/server.xml
  echo "BASIC_AUTH config : remove openIdWebSecurity from server.xml"
  sed -i '/openIdWebSecurity/d' /config/server.xml
  echo "BASIC_AUTH config : remove oidcClientWebapp from server.xml"
  sed -i '/oidcClientWebapp/d' /config/server.xml

  if [ -n "$DC_ROLE_GROUP_MAPPING" ]
  then
    echo "DC_ROLE_GROUP_MAPPING set then replace rtsAdministators/rtsConfigManagers/rtsInstallers group in /config/application.xml"
    sed -i $'/<group name="rtsAdministrators"/{e cat /config/authOidc/rtsAdministrators.xml\n}' /config/application.xml
    sed -i '/<group name="rtsAdministrators"/d' /config/application.xml
    sed -i $'/<group name="rtsInstallers"/{e cat /config/authOidc/rtsInstallers.xml\n}' /config/application.xml
    sed -i '/<group name="rtsInstallers"/d' /config/application.xml
    sed -i $'/<group name="rtsConfigManagers"/{e cat /config/authOidc/rtsConfigManagers.xml\n}' /config/application.xml
    sed -i '/<group name="rtsConfigManagers"/d' /config/application.xml

    if [ -n "$DISABLE_ALL_AUTHENTICATED_RTSUSER" ]
    then
      echo "replace ALL_AUTHENTICATED_USERS by rtsUsers group  in /config/application.xml"
      sed -i $'/<special-subject type=/{e cat /config/authOidc/rtsUsers.xml\n}' /config/application.xml
      sed -i '/<special-subject type=/d' /config/application.xml
    fi
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

if [ -n "$DISABLE_USE_AUTHENTICATION_DATA" ]
then
 echo "Set useAuthenticationDataForUnprotectedResource to false on /config/httpSession.xml"
 sed -i 's|useAuthenticationDataForUnprotectedResource="true"|useAuthenticationDataForUnprotectedResource="false"|' /config/httpSession.xml
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

if [ -n "$DECISIONSERVERCONSOLE_CONTEXT_ROOT" ]
then
  echo "Update decision server console context root to $DECISIONSERVERCONSOLE_CONTEXT_ROOT in $DC_SERVER_CONFIG"
        sed -i 's|/res|'$DECISIONSERVERCONSOLE_CONTEXT_ROOT/res'|g' $DC_SERVER_CONFIG
fi

if [ -n "$DECISIONRUNNER_CONTEXT_ROOT" ]
then
  echo "Update decision runner context root to $DECISIONRUNNER_CONTEXT_ROOT in $DC_SERVER_CONFIG"
        sed -i 's|/DecisionRunner|'$DECISIONRUNNER_CONTEXT_ROOT/DecisionRunner'|g' $DC_SERVER_CONFIG
fi

if [ -n "$DEMO" ]
then
  echo "Update flag to allow update of existing server definition in $DC_SERVER_CONFIG"
        sed -i 's|false|true|g' $DC_SERVER_CONFIG
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

if [ -n "$COM_IBM_RULES_METERING_ENABLE" ]
then
        echo "enable rules metering"
        if [ -s "/config/pluginconfig/plugin-configuration.properties" ]
        then
        	echo "Configure metering using /config/pluginconfig/plugin-configuration.properties provided config"
         	cat /config/pluginconfig/plugin-configuration.properties >> $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
        elif [ -n "$METERING_SERVER_URL" ]
        then
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

                cat /config/metering-template.properties >> $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
        fi
fi

if [ -n "$ODM_CONTEXT_ROOT" ]
then
  sed -i 's|http://localhost:9060/decisioncenter-api|'http://localhost:9060$ODM_CONTEXT_ROOT/decisioncenter-api'|g' $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

if [ -n "$RELEASE_NAME" ]
then
  echo "Prefix decision center cookie names with $RELEASE_NAME"
        sed -i 's|RELEASE_NAME|'$RELEASE_NAME'|g' /config/httpSession.xml
else
  echo "Prefix decision center cookie names with $HOSTNAME"
        sed -i 's|RELEASE_NAME|'$HOSTNAME'|g' /config/httpSession.xml
fi

function updateContextParamPropertyInWebXml() {
  if grep -q "<param-name>$1</param-name>" $APPS/decisioncenter.war/WEB-INF/web.xml; then
    echo "Setting parameter $1 to $2 in the web.xml file"
	  result="$(xmllint --shell $APPS/decisioncenter.war/WEB-INF/web.xml 2>&1 >/dev/null << EOF
setns x=http://java.sun.com/xml/ns/javaee
cd x:web-app/x:context-param[x:param-name='$1']/x:param-value
set $2
save
EOF
)"
	else
    echo "Adding context-param $1 with value $2 in the web.xml file"
    sed -i '/<\/web-app>/i\
	<context-param>\
		<param-name>'$1'</param-name>\
		<param-value>'$2'</param-value>\
	</context-param>
    ' $APPS/decisioncenter.war/WEB-INF/web.xml

	fi
}

if [ -f "/config/web-configuration.properties" ]; then
	echo "Configure context-param properties in web.xml"
	file="/config/web-configuration.properties"
	while IFS='=' read -r key value
	do
    # Check if non blank or commented line
    if [ -n "$key" ] && [[ "$key" != "#"* ]]; then
      if [[ "$key" != "maxUploadSize" ]]; then
      	updateContextParamPropertyInWebXml "$key" "$value"
      else
      	echo "replace $key by $value in /config/apps/decisioncenter.war/WEB-INF/spring/applicationContext.xml"
     	sed -i 's/property.*name=\"maxUploadSize\".*value=\".*\"/property name=\"maxUploadSize\" value=\"'$value'\"/' /config/apps/decisioncenter.war/WEB-INF/spring/applicationContext.xml
      fi
    fi
  done < <(grep . "$file")
else
  echo "No web.xml configuration file provided"
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

if [ -s "/config/auth/server-configurations.json" ]
then
  echo "Update decisioncenter-configuration.properties with provided /config/auth/server-configurations.json"
  cp /config/auth/server-configurations.json /config/server-configurations.json
fi

if [ -s "/config/auth/OdmOidcProviders.json" ]
then
  echo "Copy /config/auth/OdmOidcProviders.json resource to $APPS/decisioncenter.war/WEB-INF/classes/OdmOidcProviders.json"
  cp /config/auth/OdmOidcProviders.json $APPS/decisioncenter.war/WEB-INF/classes/OdmOidcProviders.json
  cp /config/auth/OdmOidcProviders.json $APPS/decisioncenter-api.war/WEB-INF/classes/OdmOidcProviders.json
fi

if [ -s "/config/auth/decisioncenter-configuration.properties" ]
then
  echo "Decision Center Custom Configuration with provided /config/auth/decisioncenter-configuration.properties"
  cp /config/auth/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
fi

if [ -s "/config/monitor/monitor.xml" ]
then
  echo "/config/monitor/monitor.xml found! Configure monitoring"
else
  echo "No /config/monitor/monitor.xml ! Disable monitoring"
  sed -i '/monitor/d' /config/server.xml
  sed -i '/mpMetrics/d' /config/featureManager.xml
fi
