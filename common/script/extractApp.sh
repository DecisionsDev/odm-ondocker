#!/bin/bash

if [ ! "$1" ]
then
  echo "ERROR: Please specify the file name to extract."
  return 0
fi

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

appFile=$1

if [ "$2" ]
then
  targetDir=$2
else
  targetDir=$appFile
fi

echo "Extracting $appFile to $APPS/$targetDir..."

cd $APPS
mkdir extract
unzip -q $appFile -d extract
rm -rf $appFile
mv extract $targetDir
