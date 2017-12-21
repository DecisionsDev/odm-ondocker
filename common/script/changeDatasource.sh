#!/bin/bash

# Begin - Change values for the datasource if required
if [ -n "$DB_SERVER_NAME" ]
then
	echo "Set database server name to $DB_SERVER_NAME"
	sed -i 's|dbserver|'$DB_SERVER_NAME'|g' /config/datasource.xml
fi

if [ -n "$DB_PORT_NUMBER" ]
then
	echo "Set database port number to $DB_PORT_NUMBER"
	sed -i 's|5432|'$DB_PORT_NUMBER'|g' /config/datasource.xml
fi

if [ -n "$DB_NAME" ]
then
	echo "Set database name to $DB_NAME"
	sed -i 's|odmdb|'$DB_NAME'|g' /config/datasource.xml
fi

if [ -n "$DB_USER" ]
then
	sed -i 's|odmusr|'$DB_USER'|g' /config/datasource.xml
fi

if [ -n "$DB_PASSWORD" ]
then
	sed -i 's|odmpwd|'$DB_PASSWORD'|g' /config/datasource.xml
fi
# End - Change values for the datasource if required
