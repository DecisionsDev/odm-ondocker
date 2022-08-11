#!/bin/bash

[ -n "$PGUSER_FILE" ] && export PGUSER=$(cat $PGUSER_FILE)
[ -n "$PGPASSWORD_FILE" ] && export PGPASSWORD=$(cat $PGPASSWORD_FILE)

until [ $CHECK_DB_SERVER -eq 0 ]
do
  echo "Test connection to $PGHOST on port 5432 state $CHECK_DB_SERVER"
  CHECK_DB_SERVER=$(psql -q -h $PGHOST -d $PGDATABASE -c "select 1" -p 5432 >/dev/null;echo $?)
  echo "Check $CHECK_DB_SERVER"
  sleep 2
done
