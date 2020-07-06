#!/bin/bash

if [ -n "$TZ" ]
then
        echo "Use TimeZone set to $TZ"
        sed -i "s|Europe/Paris|$TZ|g" /config/configDropins/overrides/jvm.options
fi
