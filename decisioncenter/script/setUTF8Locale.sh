#!/bin/bash

if [ -f "/etc/redhat-release" ]
then
        echo "Set UTF-8 locale to en_US.UTF-8"
        export LANG=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
else
        echo "Set locale to C.UTF-8"
        export LANG=C.UTF-8
        export LC_ALL=C.UTF-8
fi
locale
