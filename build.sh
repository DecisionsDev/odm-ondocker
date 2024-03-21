#!/bin/bash
set -ex
echo "start building odm-ondocker..."
echo "current build directory:"
pwd
cd ..

mkdir ${HOME}/.cache

echo "ODM distribution: Starting download..."
ODM_ZIP_URL=${ODM_URL}/${ODM_VERSION}/icp-docker-compose-build-images-${ODM_VERSION}.zip
curl ${ODM_ZIP_URL} -u "${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD}" -o ${HOME}/.cache/${ODM_FILE_NAME}
echo "ODM distribution: download finished..."

echo "unzip odm distribution..."
unzip -q ${HOME}/.cache/${ODM_FILE_NAME}

echo "copy odm-ondocker into ODM distribution..."
cp -R odm-ondocker install

cd install/odm-ondocker
cp resources/.dockerignore ../
# Optimizing the build to download webprofile package.
source .env
echo "Using this properties from .env file."
cat .env
docker run --user 'root' -v $PWD/wlp:/opt/wlp  $FROMLIBERTY  /bin/sh -c "mkdir -p /opt/wlp ;\
 installUtility download $PACKAGELIST --location=/opt/wlp"


echo "build ODM standard docker images..."
DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yml build

echo "build ODM standalone docker image..."
DOCKER_BUILDKIT=1 docker-compose -f odm-standalone.yml build

# echo "build ODM standalone tomcat8 docker image..."
# docker-compose -f odm-standalone-tomcat.yml build

echo "build ODM cluster docker images..."
DOCKER_BUILDKIT=1 docker-compose -f odm-cluster.yml build
