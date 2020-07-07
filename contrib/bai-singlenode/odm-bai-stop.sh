#!/bin/bash
SDIR=$(dirname "$0")
echo "Stopping ODM "
docker-compose -f odm-standalone.yml down
