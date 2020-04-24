#!/bin/bash
SDIR=$(dirname $0)
HOME_DIR=$(cd ${SDIR}/.. && pwd)
echo "Stopping ODM "
docker-compose -f odm-standalone.yml down
