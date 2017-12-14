#!/bin/bash

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

engineJarFile=$(find $APPS -name '*engine*.jar' )
odmVersion=$(java -cp $engineJarFile ilog.rules.tools.IlrVersion | sed -ne "s/Decision Server \(.*\)/\1/p")
echo $odmVersion
