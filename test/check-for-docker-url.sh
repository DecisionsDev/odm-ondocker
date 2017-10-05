#!/bin/bash

dockerimg=$1
dockerurl=$2

echo "Testing if $dockerurl is available inside $dockerimg image"

sudo docker exec -ti $dockerimg bash -c " \
    apt-get -qq update && \
    apt-get -qq install -y iputils-ping && \
    ping -q -c5 $dockerurl > /dev/null && \
    if [ $? -eq 0 ] ; then \
        echo \"$dockerimg: OK\"; \
    else \
        echo \"$dockerimg: KO\" \
        exit 1; \
    fi"
