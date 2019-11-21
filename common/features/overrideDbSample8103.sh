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

echo "running overrideDbSample8103.sh"
export DBVERSIONTOCOPY=8.10.3
if [ -d "/db8103" ]
then
rm /upload/*
cp /db8103/* /upload/
fi
