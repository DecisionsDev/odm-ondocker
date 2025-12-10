#!/bin/bash

echo "Install the feature list for ODM on Liberty"
ROOTFEATUREDIR=/opt/wlppackage

featureUtility installFeature $PACKAGELIST
