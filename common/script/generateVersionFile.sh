#!/bin/bash
VERSIONFILE="/opt/ibm/version.txt"
echo "IBM Operational Decision Manager (CloudPak) : "$CP4BAVERSION > $VERSIONFILE
echo "IBM Operational Decision Manager (ODM on Certified Kubernetes) : "$ODMVERSION >> $VERSIONFILE
LIBERTY_VERSION=$(/opt/ibm/wlp/bin/server version)
echo "Liberty : "${LIBERTY_VERSION}  >> $VERSIONFILE
JAVA_VERSION=$(java --version | head -2 | tail -1)
echo "Java : "${JAVA_VERSION}  >> $VERSIONFILE
echo "Date : " $(date) >> $VERSIONFILE
echo "Arch : " $(uname -m) >> $VERSIONFILE