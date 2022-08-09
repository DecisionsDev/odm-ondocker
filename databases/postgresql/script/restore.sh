#!/bin/sh

set +u

[ -z ${PGDATA} ] && PGDATA=/var/lib/pgsql/data/userdata
[ -f /run/secrets/postgres-config/db-user ] && export POSTGRES_USER=$(cat /run/secrets/postgres-config/db-user)
[ -f /run/secrets/postgres-config/db-password ] && export POSTGRES_PASSWORD=$(cat /run/secrets/postgres-config/db-password)

# Depending on the postgresql implementation the directory to write is not the same.
if [ -d /var/lib/pgsql ]; then
	INITFLAG=/var/lib/pgsql/initialized.flag
else
	INITFLAG=/var/lib/postgresql/initialized.flag
fi

if [ ! -f $INITFLAG ] ; then
	if [ "${SAMPLE}" = "true" ] ; then
		echo "$(date) - Restore ODM sample database "
 		pg_restore -Fc -d odmdb /upload/data.dump

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
