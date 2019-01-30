#!/bin/bash

set -e

if [ ! -f /var/lib/postgresql/initialized.flag ] ; then
	mkdir -p "$PGDATA"
	chmod 777 "$PGDATA"
        chown -R 999:999 "$PGDATA"
	if [ "$SAMPLE" = "true" ] ; then
		cp -R /upload/* "$PGDATA"
	fi;
	touch /var/lib/postgresql/initialized.flag
fi;

exec "docker-entrypoint.sh" "$@"
