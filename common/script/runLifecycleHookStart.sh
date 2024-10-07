#!/bin/bash
if [ -f "/config/lifecycleHook/start.sh" ];
  then
  echo "Running PreStart Hook"
  /config/lifecycleHook/start.sh
fi

