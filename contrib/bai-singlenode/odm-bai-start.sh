#!/bin/bash

SDIR=$(dirname $0)

HOME_DIR=$(cd ${SDIR}/.. && pwd)


CERT_DIR="${HOME_DIR}/certs/kafka/"
ENV_FILE="${HOME_DIR}/.env"

source "${ENV_FILE}"
TRUSTOREPWD=$(cat ${CERT_DIR}/store-password.txt)
TMPFILE="/tmp/tmp.properties"
ODMTEMPLATEFILE="$HOME_DIR/odm/kafka_client_odm_template.properties"
ODMPROPERTIESFILE="$HOME_DIR/odm/kafka_client_odm.properties"
rm $ODMPROPERTIESFILE

# since 20.01 BAI stores passwords using base64 encoding, using the prefix {base64}
# therefore check for encoding
PREFIX="{base64}"
STOREDPASS=$KAFKA_PASSWORD
if
	echo "$STOREDPASS" | grep -q "$PREFIX"; then
	#strip and decode
	STRIPPASS=${STOREDPASS##*\}}
	KAFKA_PASSWORD=`echo "$STRIPPASS" | base64 --decode`
	#else nothing to do!
fi
echo "clearpass: $KAFKA_PASSWORD"
sed -e "s|TRUESTOREPASSWORD|$TRUSTOREPWD|g" $ODMTEMPLATEFILE  > $TMPFILE ;  mv $TMPFILE $ODMPROPERTIESFILE
sed -e "s|KAFKAUSER|$KAFKA_USERNAME|g" $ODMPROPERTIESFILE   > $TMPFILE ;  mv $TMPFILE $ODMPROPERTIESFILE
sed -e "s|KAFKAPASSWORD|$KAFKA_PASSWORD|g" $ODMPROPERTIESFILE   > $TMPFILE ;  mv $TMPFILE $ODMPROPERTIESFILE
sed -e "s|KAFKAHOST|$KAFKA_EXTERNAL_HOSTNAME|g" $ODMPROPERTIESFILE   > $TMPFILE ;  mv $TMPFILE $ODMPROPERTIESFILE

docker-compose -f odm-standalone.yml up
