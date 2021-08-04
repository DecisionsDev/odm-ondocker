#!/bin/bash

# Install the driver for PostgreSQL
echo "Install the driver for postgreSQL"
cd /tmp
curl -O -s https://jdbc.postgresql.org/download/postgresql-42.2.23.jar
mv postgres* /config/resources
