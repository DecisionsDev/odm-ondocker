#!/bin/bash

if [ ! "$SCRIPT" ]; then
  echo "ERROR: the environment variable SCRIPT needs to be defined."
  return 0
fi

if [ ! "$APPS" ]; then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

echo "running overrideDbSample960.sh"
export DBVERSIONTOCOPY=9.6
if [ -d "/db96" ]; then
  rm /upload/*
  cp /db96/* /upload/
fi
