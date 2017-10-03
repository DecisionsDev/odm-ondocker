
echo "start building odm-ondocker..."
echo "current build directory:"
pwd
cd ../

echo "download odm distribution..."
AUTH_TOKEN=$(curl -i -H "X-Auth-User: $AUTH_USER" -H "X-Auth-Key:$AUTH_KEY" https://dal05.objectstorage.softlayer.net/auth/v1.0 | grep -E "X-Auth-Token:" | awk {'print $2'})
curl -O -H "X-Auth-Token: $AUTH_TOKEN" $ODM_URL 
#-o $HOME/CACHE/$ODM_FILE_NAME

#ls -R $HOME/CACHE
echo "unzipp odm distribution..."
unzip $ODM_FILE_NAME # $HOME/CACHE/$ODM_FILE_NAME 
# -d .

echo "copy odm-ondocker into ODM distribution..."
cp -R odm-ondocker install

cd install/odm-ondocker
cp resources/.dockerignore ../

echo "build ODM standard docker images..."
docker-compose build

echo "build ODM standalone docker image..."
docker-compose -f odm-standalone.yml build

echo "build ODM cluster docker images..."
docker-compose -f odm-cluster.yml build
