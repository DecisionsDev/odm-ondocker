#!/bin/bash

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
