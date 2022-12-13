#!/bin/bash

set -e

[ -n "$POSTGRESQL_USER_FILE" ] && export POSTGRES_USER=$(cat $POSTGRESQL_USER_FILE) && export POSTGRESQL_USER=$POSTGRES_USER
[ -n "$POSTGRESQL_PASSWORD_FILE" ] && export POSTGRES_PASSWORD=$(cat $POSTGRESQL_PASSWORD_FILE) && export POSTGRESQL_PASSWORD=$POSTGRES_PASSWORD

if type "run-postgresql" >& /dev/null ; then
	exec "run-postgresql"
else
	exec "docker-entrypoint.sh" "$@"
fi
