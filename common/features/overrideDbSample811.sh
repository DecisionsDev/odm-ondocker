#!/bin/bash

if [ ! "$SCRIPT" ]; then
  echo "ERROR: the environment variable SCRIPT needs to be defined."
  return 0
fi

if [ ! "$APPS" ]; then
  echo "ERROR: the environment variable APPS needs to be defined."
  return 0
fi

echo "running overrideDbSample811.sh"
export DBVERSIONTOCOPY=8.11
if [ -d "/db811" ]; then
  rm /upload/*
  cp /db811/* /upload/
fi
