#!/bin/bash

if [ -n "$OPENID_CONFIG" ]
then
  OPENID_PROVIDER=$(grep OPENID_PROVIDER /config/authOidc/openIdParameters.properties | sed "s/OPENID_PROVIDER=//g")
  echo "RuleDesigner Config : OPENID_PROVIDER: $OPENID_PROVIDER"
  sed -i 's|OPENID_PROVIDER|'$OPENID_PROVIDER'|g' /config/OdmOidcProvidersRD.json

  OPENID_AUTHORIZATION_URL=$(grep OPENID_AUTHORIZATION_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_AUTHORIZATION_URL=//g")
  echo "RuleDesigner Config : set authorization URL to $OPENID_AUTHORIZATION_URL"
  sed -i 's|OPENID_AUTHORIZATION_URL|'$OPENID_AUTHORIZATION_URL'|g' /config/OdmOidcProvidersRD.json
     
  OPENID_TOKEN_URL=$(grep OPENID_TOKEN_URL /config/authOidc/openIdParameters.properties | sed "s/OPENID_TOKEN_URL=//g")

  if [[ "$OPENID_TOKEN_URL" =~ "ums-sso-service" ]]
  then
    echo "RuleDesigner Config : replace URL internal service token URL endpoint by external URL"
    OPENID_TOKEN_URL=$OPENID_SERVER_URL/oidc/endpoint/ums/token
  fi

  echo "RuleDesigner Config : set token URL to $OPENID_TOKEN_URL"
  sed -i 's|OPENID_TOKEN_URL|'$OPENID_TOKEN_URL'|g' /config/OdmOidcProvidersRD.json

  if [ "$OPENID_PROVIDER" == "iam" ]
  then
    echo "RuleDesigner Config : replace identitytoken by token for the IAM token URL "
    sed -i 's/identitytoken/token/g' /config/OdmOidcProvidersRD.json
  fi

  OPENID_CLIENT_ID=$(grep OPENID_CLIENT_ID /config/authOidc/openIdParameters.properties | sed "s/OPENID_CLIENT_ID=//g")
  echo "RuleDesigner Config : set client ID to $OPENID_CLIENT_ID"
  sed -i 's|OPENID_CLIENT_ID|'$OPENID_CLIENT_ID'|g' /config/OdmOidcProvidersRD.json

  OPENID_CLIENT_SECRET=$(grep OPENID_CLIENT_SECRET /config/authOidc/openIdParameters.properties | sed "s/OPENID_CLIENT_SECRET=//g")
  echo "RuleDesigner Config : set client Secret to $OPENID_CLIENT_SECRET"
  sed -i 's|OPENID_CLIENT_SECRET|'$OPENID_CLIENT_SECRET'|g' /config/OdmOidcProvidersRD.json

  echo "copy /config/OdmOidcProvidersRD.json and /config/security/truststore.jks to /config/apps/decisioncenter.war/assets/ "
  cp /config/OdmOidcProvidersRD.json /config/apps/decisioncenter.war/assets/  
fi
cp /config/security/truststore.jks /config/apps/decisioncenter.war/assets/
