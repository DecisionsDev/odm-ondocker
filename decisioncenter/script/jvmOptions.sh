#!/bin/bash

DEFAULT_KEYSTORE_PASSWORD=changeme
DEFAULT_TRUSTSTORE_PASSWORD=changeme

if [ -f "/shared/tls/keystore/jks/server.jks" ]
then
        echo "DC JVM Options : replace /config/security/keystore.jks by /shared/tls/keystore/jks/server.jks and default keystore password"
        cp /shared/tls/keystore/jks/server.jks /config/security/keystore.jks
        DEFAULT_KEYSTORE_PASSWORD=changeit
fi

if [ -f "/shared/tls/truststore/jks/trusts.jks" ]
then
        echo "DC JVM Options : replace /config/security/trustore.jks by /shared/tls/truststore/jks/trusts.jks and default keystore password"
        cp /shared/tls/truststore/jks/trusts.jks /config/security/truststore.jks
        DEFAULT_TRUSTSTORE_PASSWORD=changeit
else
        echo "no file /shared/tls/truststore/jks/trusts.jks"
        ls -la /shared/tls/truststore/jks
fi

# Begin - Configuration for the TLS security
echo "DC JVM Options : Configure the TLS keystore password"
if [ -n "$KEYSTORE_PASSWORD" ]
then
	sed -i 's|__KEYSTORE_PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/jvm.options
else
	sed -i 's|__KEYSTORE_PASSWORD__|'$DEFAULT_KEYSTORE_PASSWORD'|g' /config/jvm.options
fi
echo "DC JVM Options : Configure the TLS truststore password"
if [ -n "$TRUSTSTORE_PASSWORD" ]
then
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$TRUSTSTORE_PASSWORD'|g' /config/jvm.options
else
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$DEFAULT_TRUSTSTORE_PASSWORD'|g' /config/jvm.options
fi
# End - Configuration for the TLS security

