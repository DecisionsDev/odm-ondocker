#!/bin/bash

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

classOAuthServerUtilFind=$(find $APPS -name '*teamserver-model*.jar' | xargs grep com.ibm.rules.decisioncenter.model.oauth.OAuthServerUtil)
echo ${classOAuthServerUtilFind##* }
