#!/bin/bash

# Install the driver for Derby
echo "Install the feature list for ODM on Liberty"
featureUtility installFeature $PACKAGELIST
