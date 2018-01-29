#!/bin/bash
set -e
echo "start building odm-ondocker..."
echo "current build directory:"
pwd
cd ../

if [ ! -f $HOME/.cache/$ODM_FILE_NAME ]; then
    echo "ODM distribution: Starting download..."
    AUTH_TOKEN=$(curl -i -H "X-Auth-User: $AUTH_USER" -H "X-Auth-Key:$AUTH_KEY" https://dal05.objectstorage.softlayer.net/auth/v1.0 | grep -E "X-Auth-Token:" | awk {'print $2'})
    curl -O -H "X-Auth-Token: $AUTH_TOKEN" $ODM_URL
    mv $ODM_FILE_NAME $HOME/.cache/
    echo "ODM distribution: download finished..."
else
    echo "ODM distribution: Loading from cache..."
    echo "ODM distribution: Loading finished..."
fi

echo "unzip odm distribution..."
unzip -q $HOME/.cache/$ODM_FILE_NAME -d install

echo "copy odm-ondocker into ODM distribution..."
cp -R odm-ondocker install

cd install/odm-ondocker
cp resources/.dockerignore ../

echo "build ODM standard docker images..."
docker-compose build

echo "build ODM standalone docker image..."
docker-compose -f odm-standalone.yml build

echo "build ODM standalone tomcat8 docker image..."
docker-compose -f odm-standalone-tomcat.yml build

echo "build ODM cluster docker images..."
docker-compose -f odm-cluster.yml build
