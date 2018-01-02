#!/bin/bash

# Begin - Configuration for the tls security
echo "Configure the tls keystore password"
if [ -n "$KEYSTORE_PASSWORD" ]
then
	sed -i 's|__PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/jvm.options
else
	sed -i 's|__PASSWORD__|'changeme'|g' /config/jvm.options
fi
# End - Configuration for the tls security
