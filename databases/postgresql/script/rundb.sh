#!/bin/bash

set -e 

if [ ! -f initialized.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		mkdir -p "$PGDATA"
		cp -R /upload/* "$PGDATA"
	fi;
	touch initialized.flag
fi;

exec "docker-entrypoint.sh" "$@"