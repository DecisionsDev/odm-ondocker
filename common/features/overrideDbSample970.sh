#!/bin/bash

if [ ! "$SCRIPT" ]; then
  echo "ERROR: the environment variable SCRIPT needs to be defined."
  return 0
fi

if [ ! "$APPS" ]; then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

echo "running overrideDbSample970.sh"
export DBVERSIONTOCOPY=9.7
if [ -d "/db97" ]; then
  rm /upload/*
  cp /db97/* /upload/
fi
