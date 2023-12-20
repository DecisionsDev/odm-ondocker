#!/bin/bash

if [ -n "$ENABLE_FIPS" ]
then
  if [[ $ENABLE_FIPS =~ "true" ]]
  then
	echo "Enable FIPS"
  fi
fi
