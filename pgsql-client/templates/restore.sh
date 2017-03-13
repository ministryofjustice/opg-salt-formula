#!/usr/bin/env bash

set -o allexport
. /root/.bash_profile
export PGPASSFILE=/root/.pgpass
set +o allexport

if [ "${1}x" == "x" ]
then
DATE_STAMP=`date "+%d%m%Y"`
else
DATE_STAMP=${1}
fi

date
echo "Restoring from backup in /tmp/${PGDATABASE}_${DATE_STAMP}.sql"
psql --quiet < /tmp/${PGDATABASE}_${DATE_STAMP}.sql
echo "Done"
