#!/bin/bash
set -e
echo "start building odm-ondocker..."
echo "current build directory:"
pwd
cd ../

if [ ! -f $HOME/.cache/$ODM_FILE_NAME ]; then
    echo "ODM distribution: Starting download..."
    ODM_ZIP_URL=${ODM_URL}/${ODM_VERSION}/icp-docker-compose-build-images-${ODM_VERSION}.zip
    curl  $ODM_ZIP_URL -u '${ARTIFACTORY_USER}:${ARTIPWD}' -o $ODM_FILE_NAME 
    echo "curl  $ODM_ZIP_URL -u '${ARTIFACTORY_USER}:${ARTIPWD}' -o $ODM_FILE_NAME"
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

# echo "build ODM standalone tomcat8 docker image..."
# docker-compose -f odm-standalone-tomcat.yml build

echo "build ODM cluster docker images..."
docker-compose -f odm-cluster.yml build
