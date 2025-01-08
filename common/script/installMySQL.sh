#!/bin/bash

# Install the driver for MySQL
echo "Install the driver for MySQL"
cd /tmp
curl -O -k -s https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.1.0/mysql-connector-j-9.1.0.jar
mv mysql* /config/resources
