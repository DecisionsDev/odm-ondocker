#!/bin/bash
# Since Liberty 18.0.O.2 RES console require to package jaxb implementaton.
echo "Running packageJaxbRuntime.sh "

# Process only for clustered topology

# Process RES Console if needed
if [ -d "$APPS/res.war" ] && [ -d "$APPS/DecisionService.war" ]; then
JAXBPATTERN="$APPS/res.war/WEB-INF/lib/jaxb*.jar"
  if  ! ls "$JAXBPATTERN" 1> /dev/null 2>&1;  then
    cp "$APPS"/DecisionService.war/WEB-INF/lib/jaxb*.jar "$APPS"/res.war/WEB-INF/lib
  fi
fi

# Process Decision Runner if needed
if [ -d "$APPS/DecisionRunner.war" ]; then
  JAXBPATTERN="$APPS/DecisionRunner.war/WEB-INF/lib/jaxb*.jar"
  if  ! ls "$JAXBPATTERN" 1> /dev/null 2>&1;  then
    cp "$THIRDPARTY"/jaxb*.jar "$APPS"/DecisionRunner.war/WEB-INF/lib
  fi
fi

# Process Decision Center if needed
if [ -d "$APPS/decisioncenter.war" ]; then
  JAXBPATTERN="$APPS/decisioncenter.war/WEB-INF/lib/jaxb*.jar"
  if  ! ls "$JAXBPATTERN" 1> /dev/null 2>&1;  then
    cp "$THIRDPARTY"/jaxb*.jar "$APPS"/decisioncenter.war/WEB-INF/lib
    cp "$THIRDPARTY"/jaxb*.jar "$APPS"/teamserver.war/WEB-INF/lib
    cp "$THIRDPARTY"/jaxb*.jar "$APPS"/decisioncenter-api.war/WEB-INF/lib
  fi
fi
