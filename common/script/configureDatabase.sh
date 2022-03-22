#!/bin/bash

defaultDatabase=$1

# Begin - Configuration for the database
if [ -n "$DB_DRIVER_URL" ]
then
	echo "Use DB_DRIVER_URL: $DB_DRIVER_URL"
  case $DB_TYPE in
    *postgres* )-
				rm /config/resources/postgres*
				;;
		*db2* )
				rm /config/resources/db2*
				;;
		*sqlserver* )
				rm /config/resources/mssql*
				;;
		*oracle* )
				rm /config/resources/ojdbc*
				;;
	esac
	(cd /config/resources && curl -O -k -s $DB_DRIVER_URL)
	if [ -f /config/resources/*.zip ]; then
		unzip -q /config/resources/*.zip -d /config/resources
	fi
fi

if [ -n "$DB_TYPE" ]
then
	echo "Use DB_TYPE: $DB_TYPE"
	case $DB_TYPE in
		*derby* )
				if [ ! -f /config/resources/derby* ]; then  /script/installDerby.sh; fi
			  cp /config/datasource-derby.xml /config/datasource.xml
			  ;;
		*mysql* )
				if [ ! -f /config/resources/mysql* ]; then /script/installMySQL.sh; fi
			  cp /config/datasource-mysql.xml /config/datasource.xml
			  ;;
		# For postgreSQL, we do not have to install the driver here since it is installed by default at build time
    *postgres* )
				cp /config/datasource-postgres.xml /config/datasource.xml
				;;
		# For DB2, we do not have to install the driver here since it is supposed to be provided through the drivers folder at build time
		*db2* )
				cp /config/datasource-db2.xml /config/datasource.xml
				;;
		# For h2, we do not have to install the driver here since it is installed by default at build time (only for the standalone topology)
		*h2* )
				cp /config/datasource-h2.xml /config/datasource.xml
			  ;;
		# For SQL server, we do not have to install the driver here since it is installed by default at build time
		*sqlserver* )
				cp /config/datasource-sqlserver.xml /config/datasource.xml
			  ;;
		# For Oracle, we do not have to install the driver here since it is supposed to be provided through the drivers folder at build time
		*oracle* )
				cp /config/datasource-oracle.xml /config/datasource.xml
				;;
	esac
else
	if [ -d "/config/customdatasource" ]; then
		echo "Use Custom datasource"
	else
		if [ "$defaultDatabase" == "h2" ]; then
			echo "Use H2 as database by default"
			cp /config/datasource-h2.xml /config/datasource.xml
		else
			echo "Use PostgreSQL as database by default"
			cp /config/datasource-postgres.xml /config/datasource.xml
		fi
	fi
fi
# End - Configuration for the database
