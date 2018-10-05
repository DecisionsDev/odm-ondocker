#!/bin/bash

if [ ! "$SCRIPT" ]
then
  echo "ERROR: the environment variable SCRIPT needs to be defined."
  return 0
fi

if [ ! "$APPS" ]
then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

echo "running overrideDbSample.sh"
export DBVERSIONTOCOPY=8.10.0
if [ -d "/db810" ]
then
rm /upload/*
cp /db810/* /upload/
fi
