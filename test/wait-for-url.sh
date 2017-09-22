#!/bin/bash

i=0
until $(curl --connect-timeout 180 --output /dev/null --silent --head --fail $1); do
    i=$((i+1))
    if [[ $i -gt 10 ]]; then
    	exit 1
    fi
    printf '.'
    sleep 10
done
