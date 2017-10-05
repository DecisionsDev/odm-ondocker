#!/bin/bash

echo "Testing url $1 availabilty."

i=0
until $(curl --connect-timeout 180 --output /dev/null --silent --head --fail $1); do
    i=$((i+1))
    if [[ $i -gt 10 ]]; then
        printf 'X'
        exit 1
    fi
    printf '.'
    sleep 10
done

printf "OK"