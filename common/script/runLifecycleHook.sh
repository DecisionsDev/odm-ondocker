#!/bin/bash
if [ -f "/config/lifecycleHook/start.sh" ];
  then
  echo "Running PreStart Hook"
  /config/lifecycleHook/start.sh
fi

if [ -f "/config/lifecycleHook/stop.sh" ];
  then
  echo "Running PreStop Hook"
  /config/lifecycleHook/stop.sh
fi

