#!/bin/bash

if [ ! "$HTTP_PORT" ]
then
  echo "HTTP_PORT unset : set 9080"
  export HTTP_PORT=9080
fi

if [ ! "$HTTPS_PORT" ]
then
  echo "HTTPS_PORT unset : set 9443"
  export HTTPS_PORT=9443
fi

echo "HTTPS_PORT : $HTTPS_PORT"
echo "HTTP_PORT : $HTTP_PORT"

if [ ! "$ODM_CONTEXT_ROOT" ]
then
  echo "ODM_CONTEXT_ROOT unset : set blank"
  export ODM_CONTEXT_ROOT=""
fi
