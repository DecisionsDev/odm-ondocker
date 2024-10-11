#!/bin/bash

echo "probe command step : $1"

if [[ $1 == "startup" ]];
then
  if [ -f "/tmp/sidecarconf/sidecar-startup-probe.sh" ];
  then
    /tmp/sidecarconf/sidecar-startup-probe.sh
  else
    exit 0;
  fi
fi

if [[ $1 == "readiness" ]];
then
  if [ -f "/tmp/sidecarconf/sidecar-readiness-probe.sh" ];
  then
    /tmp/sidecarconf/sidecar-readiness-probe.sh
  else
    exit 0;
  fi
fi

if [[ $1 == "liveness" ]];
then
  if [ -f "/tmp/sidecarconf/sidecar-liveness-probe.sh" ];
  then
    /tmp/sidecarconf/sidecar-liveness-probe.sh
  else
    exit 0;
  fi
fi
