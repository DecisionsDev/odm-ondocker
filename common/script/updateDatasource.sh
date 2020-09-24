#!/bin/bash

# Begin - Update values for the datasource if required
if [ -n "$DB_SERVER_NAME" ]
then
	echo "Set database server name to $DB_SERVER_NAME"
	sed -i 's|dbserver|'$DB_SERVER_NAME'|g' /config/datasource.xml
fi

if [ -n "$DB_PORT_NUMBER" ]
then
	echo "Set database port number to $DB_PORT_NUMBER"
	# Update port in case of PostgreSQL
	sed -i 's|5432|'$DB_PORT_NUMBER'|g' /config/datasource.xml
	# Update port in case of DB2
	sed -i 's|50000|'$DB_PORT_NUMBER'|g' /config/datasource.xml
	# Update port in case of Derby
	sed -i 's|1527|'$DB_PORT_NUMBER'|g' /config/datasource.xml
	# Update port in case of MySQL
	sed -i 's|3306|'$DB_PORT_NUMBER'|g' /config/datasource.xml
	# Update port in case of SQL server
	sed -i 's|1433|'$DB_PORT_NUMBER'|g' /config/datasource.xml
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

if [ -n "$DB_SSL_TRUSTSTORE_PASSWORD" ]
then
       sed -i 's|sslConnection="false"|sslConnection="true" sslTrustStoreLocation="/config/customdatasource/truststore.jks" sslTrustStorePassword="'$DB_SSL_TRUSTSTORE_PASSWORD'"|g' /config/datasource.xml
fi
# End - Update values for the datasource if required
