#!/bin/bash

echo "Testing url $1 availabilty."

if [ $# -ge 3 ]
then
  echo "authentication is enabled."
  auth="-u $2:$3"
fi

i=0
until $(curl $auth --connect-timeout 180 --output /dev/null --silent --head --fail $1); do
    i=$((i+1))
    if [[ $i -gt 10 ]]; then
        printf 'X'
        exit 1
    fi
    printf '.'
    sleep 15
done

printf "OK"
