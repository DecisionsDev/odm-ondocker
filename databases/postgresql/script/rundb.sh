#!/bin/bash

set -e

[ -f /run/secrets/postgres-config/db-user ] && export POSTGRES_USER=$(cat /run/secrets/postgres-config/db-user)
[ -f /run/secrets/postgres-config/db-password ] && export POSTGRES_PASSWORD=$(cat /run/secrets/postgres-config/db-password)
unset POSTGRES_USER_FILE
unset POSTGRES_PASSWORD_FILE

if type "run-postgresql" >& /dev/null ; then
	exec "run-postgresql"
else
	exec "docker-entrypoint.sh" "$@"
fi
