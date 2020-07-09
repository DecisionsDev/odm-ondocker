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
	sed -i "s|__KEYSTORE_PASSWORD__|$KEYSTORE_PASSWORD|g" /config/tlsSecurity.xml
else
	sed -i "s|__KEYSTORE_PASSWORD__|$DEFAULT_KEYSTORE_PASSWORD|g" /config/tlsSecurity.xml
fi
echo "Configure the TLS truststore password"
if [ -n "$TRUSTSTORE_PASSWORD" ]
then
	sed -i "s|__TRUSTSTORE_PASSWORD__|$TRUSTSTORE_PASSWORD|g" /config/tlsSecurity.xml
else
	sed -i "s|__TRUSTSTORE_PASSWORD__|$DEFAULT_TRUSTSTORE_PASSWORD|g" /config/tlsSecurity.xml
fi
# End - Configuration for the TLS security

if [ -f "/config/security/ldap.jks" ]
then
        if [ -n "$LDAP_TRUSTSTORE_PASSWORD" ]
        then
                echo "import /config/security/ldap.jks in trustore using provided LDAP truststore password"
        else
                echo "import /config/security/ldap.jks in trustore using default LDAP truststore password"
                LDAP_TRUSTSTORE_PASSWORD=changeit
        fi

        i=0
        mapfile -t trust_list < <(keytool -list -v -keystore /config/security/ldap.jks -storepass $LDAP_TRUSTSTORE_PASSWORD | grep "Alias name" | awk 'NF>1{print $NF}')
        for trust_file in "${trust_list[@]}"
        do
        keytool -changealias -alias "${trust_file}" -destalias "LDAP_ALIAS_FOR_ODM_"$i -keystore /config/security/ldap.jks -storepass $LDAP_TRUSTSTORE_PASSWORD
        ((i=i+1))
        done
        keytool -importkeystore -srckeystore /config/security/ldap.jks -destkeystore /config/security/truststore.jks -srcstorepass $LDAP_TRUSTSTORE_PASSWORD -deststorepass "$DEFAULT_TRUSTSTORE_PASSWORD"

else
        echo "no /config/security/ldap.jks file"
fi
