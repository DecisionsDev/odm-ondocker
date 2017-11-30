#!/bin/bash

# Install the driver for PostgreSQL
echo "Install the driver for postgreSQL"
wget -nv https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar
mv postgres* /config/resources
