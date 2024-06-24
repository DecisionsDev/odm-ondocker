#!/bin/sh

set +u

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
  		if [[ -f /run/postgresql/secrets/db-user ]]; then
    			PG_RESTORE_USER=$(cat /run/postgresql/secrets/db-user)
       		else
	 		PG_RESTORE_USER=odmusr
		fi
 		pg_restore --dbname=odmdb --format=c --no-owner --role=${PG_RESTORE_USER} /upload/data.dump

        echo "$(date) - Database restored successfully"
		echo ""
		if [ -n "$ODM_CONTEXT_ROOT" ] ; then
			echo "Updating Decision Center endpoint user setting with $ODM_CONTEXT_ROOT context."
			cp /upload/update-usersetting.sql /tmp/
			sed -i 's|ODM_CONTEXT_ROOT|'$ODM_CONTEXT_ROOT'|g' /tmp/update-usersetting.sql
			psql -U $POSTGRES_USER -d $POSTGRES_DB -f /tmp/update-usersetting.sql
			echo "Change committed."
			echo "Verifying values:"
			psql -U $POSTGRES_USER -d $POSTGRES_DB -f /upload/verify-usersetting.sql
		fi;
	fi;
	touch $INITFLAG
fi;

if [ -s "/etc/postgresql/pg_hba.conf" ]
  then
        echo "copy all .conf files to ${PGDATA}"
        cp /etc/postgresql/*.conf ${PGDATA}
fi
