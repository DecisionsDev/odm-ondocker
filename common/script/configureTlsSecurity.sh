#!/bin/bash

# Begin - Configuration for the TLS security
echo "Configure the TLS keystore password"
if [ -n "$KEYSTORE_PASSWORD" ]
then
	sed -i 's|__KEYSTORE_PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
else
	sed -i 's|__KEYSTORE_PASSWORD__|'changeme'|g' /config/tlsSecurity.xml
fi
echo "Configure the TLS truststore password"
if [ -n "$TRUSTSTORE_PASSWORD" ]
then
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$TRUSTSTORE_PASSWORD'|g' /config/tlsSecurity.xml
else
	sed -i 's|__TRUSTSTORE_PASSWORD__|'changeme'|g' /config/tlsSecurity.xml
fi
# End - Configuration for the TLS security
