#!/bin/bash

set -e

if type "run-postgresql" >& /dev/null ; then  
	exec "run-postgresql"  
else 
	exec "docker-entrypoint.sh" "$@"
fi

