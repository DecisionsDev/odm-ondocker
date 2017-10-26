#!/bin/bash
if [ ! -f /config/initialized.flag ] ; then
	cd  /config/apps/DecisionRunner.war/WEB-INF/classes;
	sed -i 's/protocol=jmx/protocol=tcpip,tcpip.port='1883',tcpip.host='odm-decisionserverconsole',tcpip.retryInterval=1000/' ra.xml;
	sed -i 's|<config-property-value>FINE</config-property-value>|<config-property-value>WARNING</config-property-value>|g' ra.xml;
	sed -i '\#<config-property-name>DefaultConnectionManagerProperties#,\#<config-property-value/># s|<config-property-value/>|<config-property-value>pool.maxSize='$CONNECTION_POOL_SIZE',pool.waitTimeout=3000</config-property-value>|' ra.xml;
    sed -i 's|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin}|{pluginClass=ilog.rules.res.decisionservice.plugin.IlrWsdlGeneratorPlugin},{pluginClass=Metering}|g' ra.xml;
	touch /config/initialized.flag
fi;

# Begin - Configuration for the user registry
if [ "$REGISTRY" = "ldap" ]
then
	echo "Use LDAP registry"
	cp /config/webSecurity-ldap.xml /config/webSecurity.xml
else
	echo "Use basic registry"
	cp /config/webSecurity-basic.xml /config/webSecurity.xml
fi
# End - Configuration for the user registry

# Begin - Configuration for the database
if [ -n "$DB_DRIVER_URL" ]
then
	echo "Use DB_DRIVER_URL: $DB_DRIVER_URL"
	wget -nv $DB_DRIVER_URL
    case $DB_DRIVER_URL in
    	*derby* ) mv derby* /config/resources 
				  cp /config/datasource-derby.xml /config/datasource.xml 
				  ;;
      	*mysql* ) mv mysql* /config/resources 
				  cp /config/datasource-mysql.xml /config/datasource.xml 
				  ;;
      	*postgres* ) mv postgres* /config/resources 
					 cp /config/datasource-postgres.xml /config/datasource.xml 
					 ;; 
	esac
elif [ -n "$DB_TYPE" ]
then
	echo "Use DB_TYPE: $DB_TYPE"
	case $DB_TYPE in
		*derby* ) /script/installDerby.sh
				  cp /config/datasource-derby.xml /config/datasource.xml 
				  ;;
		*mysql* ) /script/installMySQL.sh
				  cp /config/datasource-mysql.xml /config/datasource.xml 
				  ;;
      	*postgres* ) cp /config/datasource-postgres.xml /config/datasource.xml 
					 ;; 
	esac
else
	echo "Use PostgreSQL as database by default"
	cp /config/datasource-postgres.xml /config/datasource.xml
fi
# End - Configuration for the database

if [ -n "$DBSERVER_NAME" ] 
then 
	sed -i 's|dbserver|'$DBSERVER_NAME'|g' /config/datasource.xml
fi

/opt/ibm/docker/docker-server run defaultServer
