#!/bin/bash

# Install the driver for Derby
echo "Install the feature list for ODM on Liberty"
ROOTFEATUREDIR=/opt/wlppackage
PACKAGELIST="openidconnectclient-1.0 collectiveMember-1.0 sessionCache-1.0 ldapRegistry-3.0 localConnector-1.0 \
  microProfile-1.0 microProfile-1.2 microProfile-1.3 microProfile-1.4 monitor-1.0 restConnector-1.0 \
  requestTiming-1.0 restConnector-2.0 sessionDatabase-1.0 ssl-1.0 transportSecurity-1.0 webCache-1.0 webProfile-7.0"

if [ ! -d $ROOTFEATUREDIR/features ]; then
  mkdir -p $ROOTFEATUREDIR
  echo "Downloading features list : $PACKAGELIST"
  installUtility download  $PACKAGELIST --location=$ROOTFEATUREDIR;
fi
installUtility install $PACKAGELIST --from=$ROOTFEATUREDIR
