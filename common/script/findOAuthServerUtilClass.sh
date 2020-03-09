#!/bin/bash

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

classOAuthServerUtilFind=$(grep com.ibm.rules.decisioncenter.model.oauth.OAuthServerUtil $APPS/**/WEB-INF/lib/*teamserver-model*.jar)
echo ${classOAuthServerUtilFind##* }
