#!/bin/bash

if [ ! "$SCRIPT" ]
then
  echo "ERROR: the environment variable SCRIPT needs to be defined."
  return 0
fi

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi
echo "running disableDiagnosticWarning.sh"

if [ -d "$APPS/res.war" ]; then
  resDir=$APPS/res.war
  $SCRIPT/changeParamValue.sh onDocker false true $resDir/WEB-INF/web.xml
fi
