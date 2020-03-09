#!/bin/bash

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

engineJarFile=$(ls $APPS/*/WEB-INF/lib/*engine*.jar | sed -n 1p)
odmVersion=$(java -cp $engineJarFile ilog.rules.tools.IlrVersion | sed -ne "s/Decision Server \(.*\)/\1/p")
echo $odmVersion
