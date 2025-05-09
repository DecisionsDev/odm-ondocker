#!/bin/bash
# Using -Xshareclasses:none jvm option in keytool commands to avoid jvm errors in logs on z/os
if [ -n "$ENABLE_FIPS" ]
then
  if [[ $ENABLE_FIPS =~ "true" ]]
  then
	echo "FIPS Enabled : update configuration for FIPS"
	cp /config/tlsSecurityFIPS.xml /config/tlsSecurity.xml
	cp /config/ltpaFIPS.xml /config/ltpa.xml
  fi
fi

if [ -s "/config/auth/tlsSecurity.xml" ]
then
  echo "SSL configuration with provided /config/auth/tlsSecurity.xml"
  cp /config/auth/tlsSecurity.xml /config/tlsSecurity.xml
fi

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
if [ -f /tmp/shared-env.sh ]; then
	echo "Sourcing /tmp/shared-env.sh"
	source /tmp/shared-env.sh
fi
if [ -n "$KEYSTORE_PASSWORD" ] || [ -f /config/security/volume/keystore_password ]
then
	# Set env var if secrets are passed using mounted volumes
	[ -f /config/security/volume/keystore_password ] && KEYSTORE_PASSWORD=$(cat /config/security/volume/keystore_password)
	sed -i 's|__KEYSTORE_PASSWORD__|'$KEYSTORE_PASSWORD'|g' /config/tlsSecurity.xml
	DEFAULT_KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD
	DEFAULT_TRUSTSTORE_PASSWORD=$KEYSTORE_PASSWORD
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
	if [ -z "$KEYSTORE_PASSWORD" ]; then
		DEFAULT_KEYSTORE_PASSWORD=$TRUSTSTORE_PASSWORD
	fi
else
	sed -i 's|__TRUSTSTORE_PASSWORD__|'$DEFAULT_TRUSTSTORE_PASSWORD'|g' /config/tlsSecurity.xml
fi

if [[ (-f "/config/security/volume/tls.crt") && (-f "/config/security/volume/tls.key")]]
then
        echo "generating /config/security/keystore.jks and truststore.jks using provided /config/security/volume/tls.key and tls.crt"
        openssl pkcs12 -export -inkey /config/security/volume/tls.key -in /config/security/volume/tls.crt -name "ODM" -out /config/security/mycert.p12 -passout pass:$DEFAULT_KEYSTORE_PASSWORD
        rm /config/security/keystore.jks
        keytool -J"-Xshareclasses:none" -importkeystore -srckeystore /config/security/mycert.p12 -srcstorepass $DEFAULT_KEYSTORE_PASSWORD -srcstoretype PKCS12 -destkeystore /config/security/keystore.jks -deststoretype JKS -deststorepass $DEFAULT_KEYSTORE_PASSWORD
        rm /config/security/truststore.jks
        keytool -J"-Xshareclasses:none" -import -v -trustcacerts -alias ODM -file /config/security/volume/tls.crt -keystore /config/security/truststore.jks -storepass $DEFAULT_TRUSTSTORE_PASSWORD -storetype jks -noprompt

		sed -i 's|<ssl |<ssl serverKeyAlias="odm" |' /config/tlsSecurity.xml
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
TRUSTSTORE=/config/security/truststore.jks
CERTDIR="/config/security/trusted-cert-volume/"
if [ -d $CERTDIR ]; then
    cd $CERTDIR
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

# This part allow to import a list of PEM certificate in the JVM
 echo "Importing private certificates $dir"
PRIVATE_CERTDIR="/config/security/private-cert-volume/"
if [ -d $PRIVATE_CERTDIR ]; then
    cd $PRIVATE_CERTDIR
    for dir in *; do
        echo "Importing private certificates $dir"
        if [ -d $dir ]; then
           if [ -f $dir/tls.key ]; then
		if [ -f $dir/tls.crt ]; then
			echo "public key $dir/tls.crt has been found for the relative $dir/tls.key private key"
                	openssl pkcs12 -export -inkey $dir/tls.key -in $dir/tls.crt -name $dir -out /config/security/$dir.p12 -passout pass:$DEFAULT_KEYSTORE_PASSWORD
                	keytool -J"-Xshareclasses:none" -importkeystore -srckeystore /config/security/$dir.p12 -srcstorepass $DEFAULT_KEYSTORE_PASSWORD -srcstoretype PKCS12 -destkeystore /config/security/keystore.jks -deststoretype JKS -deststorepass $DEFAULT_KEYSTORE_PASSWORD

                        keytool -J"-Xshareclasses:none" -import -v -trustcacerts -alias $dir -file $dir/tls.crt -keystore $TRUSTSTORE -storepass $DEFAULT_TRUSTSTORE_PASSWORD -noprompt
		else
			echo "cannot register $dir/tls.key private key has the associated $dir/tls.crt public key is not present"
		fi
           else
                echo "Couldn't find certificate $dir/tls.key skipping this certificate "
           fi
        fi
    done
    echo "done"
fi

if [ -n "$ENABLED_CIPHERS" ]
then
	echo "configure enabled ciphers with $ENABLED_CIPHERS"
	sed -i "s|ENABLED_CIPHERS|${ENABLED_CIPHERS}|g" /config/tlsSecurity.xml
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


echo "Change certificate format from JKS to P12"
keytool -J"-Xshareclasses:none" -importkeystore -srckeystore /config/security/truststore.jks -srcstorepass $DEFAULT_TRUSTSTORE_PASSWORD -destkeystore /config/security/truststore.p12 -srcstoretype JKS -deststoretype PKCS12 -deststorepass $DEFAULT_TRUSTSTORE_PASSWORD -noprompt
keytool -J"-Xshareclasses:none" -importkeystore -srckeystore /config/security/keystore.jks -srcstorepass $DEFAULT_KEYSTORE_PASSWORD -destkeystore /config/security/keystore.p12 -srcstoretype JKS -deststoretype PKCS12 -deststorepass $DEFAULT_KEYSTORE_PASSWORD -noprompt


if [ -n "$ENABLE_FIPS" ]
then
  if [[ $ENABLE_FIPS =~ "true" ]]
  then
	echo "FIPS Enabled importing certification in the nssdb"
	pk12util -i /config/security/keystore.p12 -W $DEFAULT_KEYSTORE_PASSWORD -d /etc/pki/nssdb
	pk12util -i /config/security/truststore.p12 -W $DEFAULT_TRUSTSTORE_PASSWORD -d /etc/pki/nssdb
	for cert in $(certutil -L -d /etc/pki/nssdb | tail -n +5 | awk '{print $1}'); do certutil -M -n ${cert} -t CT,CT,CT -d /etc/pki/nssdb; done
  fi
fi
