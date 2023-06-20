#!/bin/bash

# Install the driver for PostgreSQL
echo "Install the driver for postgreSQL"
cd /tmp
curl -O -k -s https://jdbc.postgresql.org/download/postgresql-42.5.1.jar
mv postgres* /config/resources
