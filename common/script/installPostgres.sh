#!/bin/bash

set -e

# Install the driver for PostgreSQL
echo "Install the driver for postgreSQL"
cd /tmp
curl --fail --insecure --remote-name --remote-time --silent https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
mv postgres* /config/resources

set +e
