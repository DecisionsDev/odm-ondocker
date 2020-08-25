#!/bin/bash

set -e


[ -z ${PGDATA} ] && PGDATA=/var/lib/pgsql/data/userdata

# Depending on the postgresql implementation the directory to write is not the same.
if [ -d /var/lib/pgsql ]; then 
	INITFLAG=/var/lib/pgsql/initialized.flag
else
	INITFLAG=/var/lib/postgresql
fi

if [ ! -f $INITFLAG ] ; then
	if [ "${SAMPLE}" = "true" ] ; then
		mkdir -p ${PGDATA}
		cp -R /upload/* ${PGDATA}/
	fi;
	touch $INITFLAG
fi;

if type "run-postgresql" >& /dev/null ; then  
	exec "run-postgresql"  
else 
	exec "docker-entrypoint.sh" "$@"
fi

