#!/bin/bash

# Install the driver for Derby
echo "Install the feature list for ODM on Liberty"
ROOTFEATUREDIR=/opt/wlppackage

if [ ! -d $ROOTFEATUREDIR/features ]; then
  mkdir -p $ROOTFEATUREDIR
  echo "Downloading features list : $PACKAGELIST"
  installUtility download  $PACKAGELIST --location=$ROOTFEATUREDIR;
fi
installUtility install $PACKAGELIST --from=$ROOTFEATUREDIR
