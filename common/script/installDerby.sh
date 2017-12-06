#!/bin/bash

# Install the driver for Derby
echo "Install the driver for Derby"
wget -nv http://central.maven.org/maven2/org/apache/derby/derbyclient/10.12.1.1/derbyclient-10.12.1.1.jar
mv derby* /config/resources
