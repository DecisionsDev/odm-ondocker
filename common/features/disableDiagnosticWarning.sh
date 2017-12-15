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

$SCRIPT/changeParamValue.sh onDocker false true $APPS/res.war/WEB-INF/web.xml
