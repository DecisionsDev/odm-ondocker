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
else
	if [ -n "$DB_TYPE" ]
	then
	echo "No provided DB_PORT_NUMBER, set default database port according to $DB_TYPE"
		case $DB_TYPE in
			*derby* )
				sed -i 's|DB_PORT_NUMBER|1527|g' /config/datasource.xml
			  	;;
			*mysql* )
				sed -i 's|DB_PORT_NUMBER|3306|g' /config/datasource.xml
			  	;;
			*db2* )
				sed -i 's|DB_PORT_NUMBER|50000|g' /config/datasource.xml
				;;
			*postgres* )
				sed -i 's|DB_PORT_NUMBER|5432|g' /config/datasource.xml
			  	;;
			*sqlserver* )
				sed -i 's|DB_PORT_NUMBER|1433|g' /config/datasource.xml
			  	;;
			*oracle* )
				sed -i 's|DB_PORT_NUMBER|1521|g' /config/datasource.xml
				;;
		esac
	else
		echo "Set DB_PORT_NUMBER to 5432 as using PostgreSQL by default"
		sed -i 's|DB_PORT_NUMBER|5432|g' /config/datasource.xml
	fi
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
