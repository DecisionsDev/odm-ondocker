#!/bin/bash

# Begin - Update values for the datasource if required
if [ -n "$DB_SSL_MODE" ] || [ -f /config/customdatasource/sslmode ]
then
        [ -f /config/customdatasource/sslmode ] && export DB_SSL_MODE=$(cat /config/customdatasource/sslmode)
fi

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

if [ -n "$DB_URL" ]
then
       case $DB_TYPE in
                *oracle* )
                echo "Set database url to $DB_URL"
                sed -i '/databaseName/d' /config/datasource.xml
                sed -i '/serverName/d' /config/datasource.xml
                sed -i '/portNumber/d' /config/datasource.xml
                sed -i 's|DB_URL|'$DB_URL'|g' /config/datasource.xml

                ORACLE_TRUSTSTORE_PASSWORD=changeme
                if [ -f "/shared/tls/truststore/jks/trusts.jks" ]
                then
                        ORACLE_TRUSTSTORE_PASSWORD=changeit
                fi
                if [ -n "$TRUSTSTORE_PASSWORD" ] || [ -f /config/security/volume/truststore_password ]
                then
                        ORACLE_TRUSTSTORE_PASSWORD=$TRUSTSTORE_PASSWORD
                fi
                sed -i 's|ORACLE_TRUSTSTORE_PASSWORD|'$ORACLE_TRUSTSTORE_PASSWORD'|g' /config/datasource.xml
                ;;
        esac
else
        case $DB_TYPE in
                *oracle* )
                echo "No url"
                sed -i '/DB_URL/d' /config/datasource.xml
                sed -i '/connectionProperties/d' /config/datasource.xml
                ;;
        esac
fi

if [ -n "$DB_USER" ] || [ -f /config/secrets/db-config/db-user ]
then
	# Set env var if secrets are passed using mounted volumes
	[ -f /config/secrets/db-config/db-user ] && export DB_USER=$(cat /config/secrets/db-config/db-user)
	# Escape special caracters for sed s command
	DB_USER_ESCAPED=$(sed -e 's/[&\\/|]/\\&/g' <<<"$DB_USER")
	sed -i 's|odmusr|'$DB_USER_ESCAPED'|g' /config/datasource.xml
fi

if [ -n "$DB_PASSWORD" ] || [ -f /config/secrets/db-config/db-password ]
then
	# Set env var if secrets are passed using mounted volumes
	[ -f /config/secrets/db-config/db-password ] && export DB_PASSWORD=$(cat /config/secrets/db-config/db-password)
	# Escape special caracters for sed s command
	DB_PASSWORD_ESCAPED=$(sed -e 's/[&\\/|]/\\&/g' <<<"$DB_PASSWORD")
	sed -i 's|odmpwd|'$DB_PASSWORD_ESCAPED'|g' /config/datasource.xml
else
        case $DB_TYPE in
                *postgres* )
        	if [ -n "$DB_SSL_MODE" ]
        	then       
			echo "postgres ssl: remove password from /config/datasource.xml"
			sed -i '/odmpwd/d' /config/datasource.xml
		fi
                ;;
        esac
fi

if [ -n "$DB_SSL_TRUSTSTORE_PASSWORD" ] || [ -f /config/customdatasource/truststore_password ] || [ -f /config/customdatasource/tls.crt ]
then
        case $DB_TYPE in
                *db2* )
		# Set env var if secrets are passed using mounted volumes
		[ -f /config/customdatasource/truststore_password ] && export DB_SSL_TRUSTSTORE_PASSWORD=$(cat /config/customdatasource/truststore_password)
                if [ -n "$DB_SSL_TRUSTSTORE_PASSWORD" ]
		then
			echo "configure DB2 SSL with DB_SSL_TRUSTSTORE_PASSWORD"
			sed -i 's|sslConnection="false"|sslConnection="true" sslVersion="TLSv1.2" sslTrustStoreLocation="/config/customdatasource/truststore.jks" sslTrustStorePassword="'$DB_SSL_TRUSTSTORE_PASSWORD'"|g' /config/datasource.xml
		else
			echo "configure DB2 SSL with DEFAULT_TRUSTSTORE_PASSWORD"
			DEFAULT_TRUSTSTORE_PASSWORD=changeme
			if [ -f "/shared/tls/truststore/jks/trusts.jks" ]
			then
				DEFAULT_TRUSTSTORE_PASSWORD=changeit
			fi
			sed -i 's|sslConnection="false"|sslConnection="true" sslVersion="TLSv1.2" sslTrustStoreLocation="/config/security/truststore.p12" sslTrustStorePassword="'$DEFAULT_TRUSTSTORE_PASSWORD'"|g' /config/datasource.xml
                        if [ -f /config/customdatasource/tls.crt ]
                        then
                                echo "Import DB2 certificate"
                                keytool -J"-Xshareclasses:none" -import -v -trustcacerts -alias BD2_FOR_ODM -file /config/customdatasource/tls.crt -keystore /config/security/truststore.jks -storepass $DEFAULT_TRUSTSTORE_PASSWORD -noprompt
                        fi
			keytool -importkeystore -srckeystore /config/security/truststore.jks -srcstorepass $DEFAULT_TRUSTSTORE_PASSWORD -destkeystore /config/security/truststore.p12 -srcstoretype JKS -deststoretype PKCS12 -deststorepass $DEFAULT_TRUSTSTORE_PASSWORD -noprompt
		fi
		;;
	esac
fi

if [ -n "$DB_SSL_MODE" ]
then
        case $DB_TYPE in
                *postgres* )

		echo "postgres ssl : generating /config/security/tls.der and key.pk8 using provided /config/customdatasource/tls.key and tls.crt"
		openssl x509 -in  /config/customdatasource/tls.crt -inform pem -outform der -out /config/security/tls.der
		openssl pkcs8 -topk8 -in /config/customdatasource/tls.key -inform pem -outform der -out /config/security/key.pk8 -nocrypt

		if [[ "$DB_SSL_MODE" == "require" ]];
        	then
			sed -i 's|sslMode="prefer"|sslMode="require" ssl="true" sslCert="/config/security/tls.der" sslKey="/config/security/key.pk8"|g' /config/datasource.xml
		elif [[ "$DB_SSL_MODE" =~ "verify" ]];
		then		
			sed -i 's|sslMode="prefer"|sslMode="'$DB_SSL_MODE'" ssl="true" sslCert="/config/security/tls.der" sslKey="/config/security/key.pk8" sslRootCert="/config/customdatasource/ca.crt"|g' /config/datasource.xml
		fi
                ;;
        esac
fi
# End - Update values for the datasource if required
