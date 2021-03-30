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
	sed -i 's|DB_PORT_NUMBER|'$DB_PORT_NUMBER'|g' /config/datasource.xml
fi

if [ -n "$DB_NAME" ]
then
	echo "Set database name to $DB_NAME"
	sed -i 's|odmdb|'$DB_NAME'|g' /config/datasource.xml
fi

if [ -n "$DB_USER" ]
then
	# Escape special caracters for sed s command
	DB_USER_ESCAPED=$(sed -e 's/[&\\/|]/\\&/g' <<<"$DB_USER")
	sed -i 's|odmusr|'$DB_USER_ESCAPED'|g' /config/datasource.xml
fi

if [ -n "$DB_PASSWORD" ]
then
	# Escape special caracters for sed s command
	DB_PASSWORD_ESCAPED=$(sed -e 's/[&\\/|]/\\&/g' <<<"$DB_PASSWORD")
	sed -i 's|odmpwd|'$DB_PASSWORD_ESCAPED'|g' /config/datasource.xml
fi

if [ -n "$DB_SSL_TRUSTSTORE_PASSWORD" ]
then
       sed -i 's|sslConnection="false"|sslConnection="true" sslTrustStoreLocation="/config/customdatasource/truststore.jks" sslTrustStorePassword="'$DB_SSL_TRUSTSTORE_PASSWORD'"|g' /config/datasource.xml
fi
# End - Update values for the datasource if required
