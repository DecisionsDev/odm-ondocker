#!/bin/bash

if [ -f "/config/lifecycleHook/stop.sh" ];
  then
  echo "Running PreStop Hook"
  /config/lifecycleHook/stop.sh
fi

