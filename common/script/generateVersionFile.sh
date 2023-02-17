#!/bin/bash
VERSIONFILE="/opt/ibm/version.txt"
echo "IBM Operational Decision Manager (CloudPak) : "$CP4BAVERSION > $VERSIONFILE
echo "IBM Operational Decision Manager (ODM on Certified Kubernetes) :"$ODMVERSION >> $VERSIONFILE