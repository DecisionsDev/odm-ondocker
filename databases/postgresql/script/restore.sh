#!/bin/sh



[ -z ${PGDATA} ] && PGDATA=/var/lib/pgsql/data/userdata

# Depending on the postgresql implementation the directory to write is not the same.
if [ -d /var/lib/pgsql ]; then 
	INITFLAG=/var/lib/pgsql/initialized.flag
else
	INITFLAG=/var/lib/postgresql/initialized.flag
fi

if [ ! -f $INITFLAG ] ; then
	if [ "${SAMPLE}" = "true" ] ; then
		echo "$(date) - Restore ODM sample database"
        pg_restore -Fc -d odmdb /upload/data-8.10.next.dump
        echo "$(date) - Database restored successfully"
	fi;
	touch $INITFLAG
fi;
