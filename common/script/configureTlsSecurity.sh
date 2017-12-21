#!/bin/bash

# Begin - Configuration for the tls security
echo "Configure the tls keystore password"
if [ -n "$KEYSTORE_PASSWORD" ]
then
	sed -i 's|__PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
else
	sed -i 's|__PASSWORD__|'changeme'|g' /config/tlsSecurity.xml
fi
# End - Configuration for the tls security
