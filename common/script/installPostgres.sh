#!/bin/bash

# Install the driver for PostgreSQL
echo "Install the driver for postgreSQL"
wget -nv https://jdbc.postgresql.org/download/postgresql-42.1.4.jar
mv postgres* /config/resources
