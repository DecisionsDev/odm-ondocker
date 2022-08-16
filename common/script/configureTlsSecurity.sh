#!/bin/bash
# Using -Xshareclasses:none jvm option in keytool commands to avoid jvm errors in logs on z/os

DEFAULT_KEYSTORE_PASSWORD=changeme
DEFAULT_TRUSTSTORE_PASSWORD=changeme

if [ -f "/shared/tls/keystore/jks/server.jks" ]
then
	echo "replace /config/security/keystore.jks by /shared/tls/keystore/jks/server.jks and default keystore password"
	cp /shared/tls/keystore/jks/server.jks /config/security/keystore.jks
        DEFAULT_KEYSTORE_PASSWORD=changeit

	if [ -n "$ROOTCA_KEYSTORE_PASSWORD" ] || [ -f /config/secrets/dba-env-context/sslKeystorePassword ]
	then
		# Set env var if secrets are passed using mounted volumes
		[ -f /config/secrets/dba-env-context/sslKeystorePassword ] && export ROOTCA_KEYSTORE_PASSWORD=$(cat /config/secrets/dba-env-context/sslKeystorePassword)
		echo "change default keystore password with provided Root CA keystore password"
		DEFAULT_KEYSTORE_PASSWORD=$ROOTCA_KEYSTORE_PASSWORD
	fi
fi

if [ -f "/shared/tls/truststore/jks/trusts.jks" ]
then
	echo "replace /config/security/trustore.jks by /shared/tls/truststore/jks/trusts.jks and default keystore password"
	cp /shared/tls/truststore/jks/trusts.jks /config/security/truststore.jks
	DEFAULT_TRUSTSTORE_PASSWORD=changeit

	if [ -n "$ROOTCA_TRUSTSTORE_PASSWORD" ] || [ -f /config/secrets/dba-env-context/sslTruststorePassword ]
	then
		# Set env var if secrets are passed using mounted volumes
		[ -f /config/secrets/dba-env-context/sslTruststorePassword ] && export ROOTCA_TRUSTSTORE_PASSWORD=$(cat /config/secrets/dba-env-context/sslTruststorePassword)
		echo "change default truststore password with provided Root CA truststore password"
		DEFAULT_TRUSTSTORE_PASSWORD=$ROOTCA_TRUSTSTORE_PASSWORD
	fi
else
        echo "no file /shared/tls/truststore/jks/trusts.jks"
fi

# Begin - Configuration for the TLS security

if [ -f "/config/security/volume/keystore.jks" ]
then
        echo "replace /config/security/keystore.jks by /config/security/volume/keystore.jks"
        cp /config/security/volume/keystore.jks /config/security/keystore.jks
fi

if [ -f "/config/security/volume/truststore.jks" ]
then
        echo "replace /config/security/truststore.jks by /config/security/volume/truststore.jks"
        cp /config/security/volume/truststore.jks /config/security/truststore.jks
fi

echo "Configure the TLS keystore password"
if [ -n "$KEYSTORE_PASSWORD" ] || [ -f /config/security/volume/keystore_password ]
then
	# Set env var if secrets are passed using mounted volumes
	[ -f /config/security/volume/keystore_password ] && KEYSTORE_PASSWORD=$(cat /config/security/volume/keystore_password)
	sed -i 's|__KEYSTORE_PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
        DEFAULT_KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD
else
	sed -i 's|__KEYSTORE_PASSWORD__|'$DEFAULT_KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
fi
echo "Configure the TLS truststore password"
if [ -n "$TRUSTSTORE_PASSWORD" ] || [ -f /config/security/volume/truststore_password ]
then
	# Set env var if secrets are passed using mounted volumes
	[ -f /config/security/volume/truststore_password ] && TRUSTSTORE_PASSWORD=$(cat /config/security/volume/truststore_password)
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$TRUSTSTORE_PASSWORD'|g' /config/tlsSecurity.xml
        DEFAULT_TRUSTSTORE_PASSWORD=$TRUSTSTORE_PASSWORD
else
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$DEFAULT_TRUSTSTORE_PASSWORD'|g' /config/tlsSecurity.xml
fi

if [[ (-f "/config/security/volume/tls.crt") && (-f "/config/security/volume/tls.key")]]
then
        echo "generating /config/security/keystore.jks and truststore.jks using provided /config/security/volume/tls.key and tls.crt"
        openssl pkcs12 -export -inkey /config/security/volume/tls.key -in /config/security/volume/tls.crt -name "certificate" -out /config/security/mycert.p12 -passout pass:$DEFAULT_KEYSTORE_PASSWORD
        rm /config/security/keystore.jks
        keytool -importkeystore -srckeystore /config/security/mycert.p12 -srcstorepass $DEFAULT_KEYSTORE_PASSWORD -srcstoretype PKCS12 -destkeystore /config/security/keystore.jks -deststoretype JKS -deststorepass $DEFAULT_KEYSTORE_PASSWORD
        rm /config/security/truststore.jks
        keytool -import -v -trustcacerts -alias ODM -file /config/security/volume/tls.crt -keystore /config/security/truststore.jks -storepass $DEFAULT_TRUSTSTORE_PASSWORD -storetype jks -noprompt
fi
# End - Configuration for the TLS security

if [ -f "/config/ldap/ldap.jks" ]
then
	if [ -n "$LDAP_TRUSTSTORE_PASSWORD" ] || [ -f /config/secrets/dba-env-context/ldapSslTruststorePassword ]
	then
		# Set env var if secrets are passed using mounted volumes
		[ -f /config/secrets/dba-env-context/ldapSslTruststorePassword ] && export LDAP_TRUSTSTORE_PASSWORD=$(cat /config/secrets/dba-env-context/ldapSslTruststorePassword)
		echo "import /config/ldap/ldap.jks in trustore using provided LDAP truststore password"
	else
		echo "import /config/ldap/ldap.jks in trustore using default LDAP truststore password"
		LDAP_TRUSTSTORE_PASSWORD=changeit
	fi

	i=0
	mapfile -t trust_list < <(keytool -J"-Xshareclasses:none" -list -v -keystore /config/ldap/ldap.jks -storepass $LDAP_TRUSTSTORE_PASSWORD | grep "Alias name" | awk 'NF>1{print $NF}')
	for trust_file in "${trust_list[@]}"
	do
	keytool -J"-Xshareclasses:none" -changealias -alias ${trust_file} -destalias "LDAP_ALIAS_FOR_ODM_"$i -keystore /config/ldap/ldap.jks -storepass $LDAP_TRUSTSTORE_PASSWORD
	((i=i+1))
	done
	keytool -J"-Xshareclasses:none" -importkeystore -srckeystore /config/ldap/ldap.jks -destkeystore /config/security/truststore.jks -srcstorepass $LDAP_TRUSTSTORE_PASSWORD -deststorepass $DEFAULT_TRUSTSTORE_PASSWORD

else
  echo "no /config/ldap/ldap.jks file"
fi

# This part allow to import a list of PEM certificate in the JVM
 echo "Importing trusted certificates $dir"
CERTDIR="/config/security/trusted-cert-volume/"
if [ -d $CERTDIR ]; then
    cd $CERTDIR
    TRUSTSTORE=/config/security/truststore.jks
    i=0
    for file in $(find . -name "*.crt")
    do
        echo "Importing trusted certificates $file"
        i=$((i+1))
        ALIASNAME="trust_$i_$file"
        keytool -J"-Xshareclasses:none" -delete -alias 0$ALIASNAME -storepass $DEFAULT_TRUSTSTORE_PASSWORD -keystore $TRUSTSTORE > /dev/null
        keytool -J"-Xshareclasses:none" -import -v -trustcacerts -alias 0$ALIASNAME -file $file -keystore $TRUSTSTORE -storepass $DEFAULT_TRUSTSTORE_PASSWORD -noprompt
    done
    echo "done"
fi

if [ -f "/config/resources/ibm-public.crt" ]
then
        echo "Importing IBM Public certificate"
        keytool -J"-Xshareclasses:none" -import -v -trustcacerts -alias IBM-PUBLIC -file /config/resources/ibm-public.crt -keystore /config/security/truststore.jks -storepass $DEFAULT_TRUSTSTORE_PASSWORD -noprompt
fi

if [ -f "/config/resources/ibm-docs.crt" ]
then
        echo "Importing IBM Docs certificate"
        keytool -J"-Xshareclasses:none" -import -v -trustcacerts -alias IBM-DOCS -file /config/resources/ibm-docs.crt -keystore /config/security/truststore.jks -storepass $DEFAULT_TRUSTSTORE_PASSWORD -noprompt
fi
