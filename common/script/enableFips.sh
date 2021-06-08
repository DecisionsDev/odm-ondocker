#!/bin/bash

if [ -n "$ENABLE_FIPS" ]
then
  if [[ $ENABLE_FIPS =~ "true" ]]
  then
	echo "Enable FIPS"
	cp  /config/jvm/enablefips-jvm.options /config/configDropins/overrides/jvm.options
	cp /config/jvm/enablefips-java.security /opt/ibm/java/jre/lib/security/java.security
  fi
fi
