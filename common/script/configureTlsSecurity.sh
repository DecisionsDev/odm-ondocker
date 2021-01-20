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

if [ -f "/config/ldap/ldap.jks" ]
then
        if [ -n "$LDAP_TRUSTSTORE_PASSWORD" ]
        then
                echo "import /config/ldap/ldap.jks in trustore using provided LDAP truststore password"
        else
                echo "import /config/ldap/ldap.jks in trustore using default LDAP truststore password"
                LDAP_TRUSTSTORE_PASSWORD=changeit
        fi

        i=0
        mapfile -t trust_list < <(keytool -list -v -keystore /config/ldap/ldap.jks -storepass $LDAP_TRUSTSTORE_PASSWORD | grep "Alias name" | awk 'NF>1{print $NF}')
        for trust_file in "${trust_list[@]}"
        do
        keytool -changealias -alias ${trust_file} -destalias "LDAP_ALIAS_FOR_ODM_"$i -keystore /config/ldap/ldap.jks -storepass $LDAP_TRUSTSTORE_PASSWORD
        ((i=i+1))
        done
        keytool -importkeystore -srckeystore /config/ldap/ldap.jks -destkeystore /config/security/truststore.jks -srcstorepass $LDAP_TRUSTSTORE_PASSWORD -deststorepass $DEFAULT_TRUSTSTORE_PASSWORD

else
        echo "no /config/ldap/ldap.jks file"
fi

# This part allow to import a list of PEM certificate in the JVM
 echo "Importing trusted certificates $dir"
CERTDIR="/config/security/trusted-cert-volume/"
TMPTRUSTORE="/config/security/trusted-cert-volume/truststore.jks"
if [ -d $CERTDIR ]; then 
    cd $CERTDIR
    for dir in *; do
        echo "Importing trusted certificates $dir"
        if [ -d $dir ]; then 
           if [ -f $dir/tls.crt ]; then
                if [ -f $TMPTRUSTORE ]; then
                        rm $TMPTRUSTORE
                fi 
                # Don't know if we need to delete the Alias. If don't delete it there is an error 
                keytool -delete -alias 0trust_$dir -storepass $DEFAULT_TRUSTSTORE_PASSWORD -keystore /config/security/truststore.jks > /dev/null
                keytool -import -v -trustcacerts -alias 0trust_$dir -file $dir/tls.crt -keystore $TMPTRUSTORE -storepass password -noprompt 
                keytool -importkeystore -srckeystore $TMPTRUSTORE -destkeystore /config/security/truststore.jks -srcstorepass password -deststorepass $DEFAULT_TRUSTSTORE_PASSWORD
           else
                echo "Couldn't find certificate $dir/tls.crt skipping this certificate "
           fi
        fi 
    done
    echo "done"
fi
