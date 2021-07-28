#!/bin/bash
set -e
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
 installUtility download openidconnectclient-1.0 collectiveMember-1.0 sessionCache-1.0 ldapRegistry-3.0 localConnector-1.0 \
  microProfile-1.0 microProfile-1.2 microProfile-1.3 microProfile-1.4 monitor-1.0 restConnector-1.0 \
  requestTiming-1.0 restConnector-2.0 sessionDatabase-1.0 ssl-1.0 transportSecurity-1.0 webCache-1.0 \
  webProfile-7.0 webProfile-7.0 --location=/opt/wlp"


echo "build ODM standard docker images..."
DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yml build

echo "build ODM standalone docker image..."
DOCKER_BUILDKIT=1 docker-compose -f odm-standalone.yml build

# echo "build ODM standalone tomcat8 docker image..."
# docker-compose -f odm-standalone-tomcat.yml build

echo "build ODM cluster docker images..."
DOCKER_BUILDKIT=1 docker-compose -f odm-cluster.yml build
