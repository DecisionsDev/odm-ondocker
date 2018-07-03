#!/bin/bash
# Since Liberty 18.0.O.2 RES console require to package jaxb implementaton.
set -x
echo "running packageJaxbRuntime.sh "

WLPPATTERN="$APPS/res.war/WEB-INF/lib/jaxb*.jar"
if  ! ls $WLPPATTERN 1> /dev/null 2>&1;  then
  if [ -d "$APPS/res.war" ] && [ -d "$APPS/DecisionService.war" ]; then
    cp $APPS/DecisionService.war/WEB-INF/lib/jaxb*.jar $APPS/res.war/WEB-INF/lib
  else
    fail "Jaxb could not be repackaged"
  fi
fi
