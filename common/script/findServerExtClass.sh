#!/bin/bash

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

classServerExtFind=$(grep com.ibm.rules.decisioncenter.model.ServerExt "$APPS"/**/WEB-INF/lib/*teamserver-model*.jar)
echo "${classServerExtFind##* }"
