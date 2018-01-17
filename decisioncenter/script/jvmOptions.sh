#!/bin/bash

# Begin - Configuration for the TLS security
echo "Configure the TLS keystore password"
if [ -n "$KEYSTORE_PASSWORD" ]
then
	sed -i 's|__KEYSTORE_PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/jvm.options
else
	sed -i 's|__KEYSTORE_PASSWORD__|'changeme'|g' /config/jvm.options
fi
echo "Configure the TLS truststore password"
if [ -n "$TRUSTSTORE_PASSWORD" ]
then
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$TRUSTSTORE_PASSWORD'|g' /config/jvm.options
else
	sed -i 's|__TRUSTSTORE_PASSWORD__|'changeme'|g' /config/jvm.options
fi
# End - Configuration for the TLS security
