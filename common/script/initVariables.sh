#!/bin/bash

if [ ! "$HTTP_PORT" ]
then
  echo "HTTP_PORT unset : set $1"
  export HTTP_PORT=$1
fi

if [ ! "$HTTPS_PORT" ]
then
  echo "HTTPS_PORT unset : set $2"
  export HTTPS_PORT=$2
fi

echo "HTTPS_PORT : $HTTPS_PORT"
echo "HTTP_PORT : $HTTP_PORT"

if [ ! "$ODM_CONTEXT_ROOT" ]
then
  echo "ODM_CONTEXT_ROOT unset : set blank"
  export ODM_CONTEXT_ROOT=""
fi

if [ -s "$SCRIPT/container.env" ]
then
    set -o allexport
    source $SCRIPT/container.env
    set +o allexport
fi