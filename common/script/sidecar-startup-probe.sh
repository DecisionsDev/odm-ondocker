#!/bin/bash

if [ -f "/tmp/sidecarconf/sidecar-startup-probe.sh" ];
then
  /tmp/sidecarconf/sidecar-startup-probe.sh
else
  exit 0;
fi
