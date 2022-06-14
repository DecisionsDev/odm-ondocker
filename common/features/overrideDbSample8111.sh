#!/bin/bash

if [ ! "$SCRIPT" ]; then
  echo "ERROR: the environment variable SCRIPT needs to be defined."
  return 0
fi

if [ ! "$APPS" ]; then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

echo "running overrideDbSample8111.sh"
export DBVERSIONTOCOPY=8.11.1
if [ -d "/db8111" ]; then
  rm /upload/*
  cp /db8111/* /upload/
fi
