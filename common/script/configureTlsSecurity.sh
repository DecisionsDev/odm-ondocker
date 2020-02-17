#!/bin/bash

DEFAULT_KEYSTORE_PASSWORD=changeme
DEFAULT_TRUSTSTORE_PASSWORD=changeme

if [ -f "/shared/tls/keystore/jks/server.jks" ]
then
	echo "replace /config/security/keystore.jks by /shared/tls/keystore/jks/server.jks and default keystore password"
	cp /shared/tls/keystore/jks/server.jks /config/security/keystore.jks
        DEFAULT_KEYSTORE_PASSWORD=changeit
	
	if [ -n "$ROOTCA_KEYSTORE_PASSWORD" ]
        then
		echo "change default keystore password with provided Root CA keystore password"
		DEFAULT_KEYSTORE_PASSWORD=$ROOTCA_KEYSTORE_PASSWORD
	fi
fi

if [ -f "/shared/tls/truststore/jks/trusts.jks" ]
then
	echo "replace /config/security/trustore.jks by /shared/tls/truststore/jks/trusts.jks and default keystore password"
	cp /shared/tls/truststore/jks/trusts.jks /config/security/truststore.jks
	DEFAULT_TRUSTSTORE_PASSWORD=changeit

        if [ -n "$ROOTCA_TRUSTSTORE_PASSWORD" ]
        then
                echo "change default truststore password with provided Root CA truststore password"
                DEFAULT_TRUSTSTORE_PASSWORD=$ROOTCA_TRUSTSTORE_PASSWORD
        fi
else
        echo "no file /shared/tls/truststore/jks/trusts.jks"
        ls -la /shared/tls/truststore/jks
fi

# Begin - Configuration for the TLS security
echo "Configure the TLS keystore password"
if [ -n "$KEYSTORE_PASSWORD" ]
then
	sed -i 's|__KEYSTORE_PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
else
	sed -i 's|__KEYSTORE_PASSWORD__|'$DEFAULT_KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
fi
echo "Configure the TLS truststore password"
if [ -n "$TRUSTSTORE_PASSWORD" ]
then
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$TRUSTSTORE_PASSWORD'|g' /config/tlsSecurity.xml
else
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$DEFAULT_TRUSTSTORE_PASSWORD'|g' /config/tlsSecurity.xml
fi
# End - Configuration for the TLS security
