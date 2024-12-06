#!/bin/bash

if [ -f "/tmp/sidecarconf/sidecar-liveness-probe.sh" ];
then
  /tmp/sidecarconf/sidecar-liveness-probe.sh
else
  exit 0;
fi
