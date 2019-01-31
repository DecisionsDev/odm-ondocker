#!/bin/bash

set -e

if [ ! -f /var/lib/postgresql/initialized.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		mkdir -p "$PGDATA"
		cp -R /upload/* "$PGDATA"
	fi;
	touch /var/lib/postgresql/initialized.flag
fi;

exec "docker-entrypoint.sh" "$@"
