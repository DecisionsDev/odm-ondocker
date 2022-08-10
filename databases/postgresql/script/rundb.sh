#!/bin/bash

set -e

[ -f /run/secrets/postgres-config/db-user ] && export POSTGRES_USER=$(cat /run/secrets/postgres-config/db-user) && export POSTGRESQL_USER=$(cat /run/secrets/postgres-config/db-user)
[ -f /run/secrets/postgres-config/db-password ] && export POSTGRES_PASSWORD=$(cat /run/secrets/postgres-config/db-password) && export POSTGRESQL_PASSWORD=$(cat /run/secrets/postgres-config/db-password)

if type "run-postgresql" >& /dev/null ; then
	exec "run-postgresql"
else
	exec "docker-entrypoint.sh" "$@"
fi
