#!/bin/bash

if [ -f "/tmp/sidecarconf/sidecar-readiness-probe.sh" ];
then
  /tmp/sidecarconf/sidecar-readiness-probe.sh
else
  exit 0;
fi
