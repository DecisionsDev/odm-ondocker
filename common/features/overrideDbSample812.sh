#!/bin/bash

if [ ! "$SCRIPT" ]; then
  echo "ERROR: the environment variable SCRIPT needs to be defined."
  return 0
fi

if [ ! "$APPS" ]; then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

echo "running overrideDbSample812.sh"
export DBVERSIONTOCOPY=8.12
if [ -d "/db812" ]; then
  rm /upload/*
  cp /db812/* /upload/
fi
