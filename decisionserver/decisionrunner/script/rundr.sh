#!/bin/bash
if [ ! -f /config/initialized.flag ] ; then
	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
    sed -i 's|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin}|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin},{pluginClass=Metering}|g' ra.xml;
    perl -i -p0e 's/(<param-name>RES_URL<\/param-name>.*?)(<param-value\/>)/\1<param-value><\/param-value>/s' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
    perl -i -p0e 's/(<param-name>RES_URL<\/param-name>.*?<param-value>)(.*?)(<\/param-value>)/\1http:\/\/odm-decisionserverconsole:9080\/res\3/s' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
	touch /config/initialized.flag
fi;

if [ -n "$DECISIONSERVERCONSOLE_NAME" ]
then
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/DecisionRunner.war/WEB-INF/classes/ra.xml;
	sed -i 's|odm-decisionserverconsole|'$DECISIONSERVERCONSOLE_NAME'|g' /config/apps/DecisionRunner.war/WEB-INF/web.xml;
fi

# Begin - Configuration for the tls security
if [ -n "$KEYSTORE_PASSWORD" ]
then
	sed -i 's|__PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
else
	sed -i 's|__PASSWORD__|'password'|g' /config/tlsSecurity.xml
fi
# End - Configuration for the tls security

# Begin - Configuration for the user registry
# For kubernetes in the case of a user want to override the configuration
if [ ! -f "/config/webSecurity.xml" ]
then
	if [ "$REGISTRY" = "ldap" ]
	then
		echo "Use LDAP registry"
		cp /config/webSecurity-ldap.xml /config/webSecurity.xml
	else
		echo "Use basic registry"
		cp /config/webSecurity-basic.xml /config/webSecurity.xml
	fi
fi
# End - Configuration for the user registry

# Begin - Configuration for the database
if [ -n "$DB_DRIVER_URL" ]
then
	echo "Use DB_DRIVER_URL: $DB_DRIVER_URL"
	wget -nv $DB_DRIVER_URL
    case $DB_DRIVER_URL in
    	*derby* ) rm /config/resources/derby*
				  mv derby* /config/resources
				  cp /config/datasource-derby.xml /config/datasource.xml
				  ;;
      	*mysql* ) rm /config/resources/mysql*
				  mv mysql* /config/resources
				  cp /config/datasource-mysql.xml /config/datasource.xml
				  ;;
      	*postgres* ) rm /config/resources/postgres*
					 mv postgres* /config/resources
					 cp /config/datasource-postgres.xml /config/datasource.xml
					 ;;
		*db2* ) rm /config/resources/db2*
				mv db2* /config/resources
				cp /config/datasource-db2.xml /config/datasource.xml
				;;
	esac
elif [ -n "$DB_TYPE" ]
then
	echo "Use DB_TYPE: $DB_TYPE"
	case $DB_TYPE in
		*derby* ) if [ ! -f /config/resources/derby* ]; then  /script/installDerby.sh; fi
				  cp /config/datasource-derby.xml /config/datasource.xml
				  ;;
		*mysql* ) if [ ! -f /config/resources/mysql* ]; then /script/installMySQL.sh; fi
				  cp /config/datasource-mysql.xml /config/datasource.xml
				  ;;
		# For postgreSQL, we do not have to install the driver here since it is installed by default at build time
      	*postgres* ) cp /config/datasource-postgres.xml /config/datasource.xml
					 ;;
		# For DB2, we do not have to install the driver here since it is supposed to be provided through the drivers folder at build time
		*db2* ) cp /config/datasource-db2.xml /config/datasource.xml
				;;
	esac
else
	echo "Use PostgreSQL as database by default"
	cp /config/datasource-postgres.xml /config/datasource.xml
fi
# End - Configuration for the database

# Begin - Change values for the datasource if required
if [ -n "$DB_SERVER_NAME" ]
then
	sed -i 's|dbserver|'$DB_SERVER_NAME'|g' /config/datasource.xml
fi
if [ -n "$DB_PORT_NUMBER" ]
then
	sed -i 's|5432|'$DB_PORT_NUMBER'|g' /config/datasource.xml
fi
if [ -n "$DB_NAME" ]
then
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

/opt/ibm/docker/docker-server run defaultServer
