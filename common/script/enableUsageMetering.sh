#!/bin/bash

if [ -n "$COM_IBM_RULES_USAGE_METERING_ENABLE" ] && [ "$COM_IBM_RULES_USAGE_METERING_ENABLE" = "true" ]
then
    echo "Usage Metering is enabled"
    cat /config/jvm/jvm-usage-metering-template.options >> /config/jvm.options
fi