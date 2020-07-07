#!/bin/bash

tcpipPort=1883

if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
  tcpipHost="$DECISIONSERVERCONSOLE_NAME"
else
  echo "ERROR: The environment variable DECISIONSERVERCONSOLE_NAME is not configured. It specifies the host name of Decision Server Consolethat the tcpip notification plugin of Decision Server Runtime connects to."
  exit 1
fi

echo "Enable tcpip notification between Decision Server Runtime XU and Decision Server Console $tcpipHost on port $tcpipPort"

sed -i "s/protocol=jmx/protocol=tcpip,tcpip.port=$tcpipPort,tcpip.host=$tcpipHost,tcpip.retryInterval=1000/" "$APPS"/DecisionService.war/WEB-INF/classes/ra.xml;
