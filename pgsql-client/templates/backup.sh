#!/usr/bin/env bash

set -o allexport
. /root/.bash_profile
export PGPASSFILE=/root/.pgpass
set +o allexport

DATE_STAMP=`date "+%d%m%Y"`
echo "Writing backup to /tmp/${PGDATABASE}_${DATE_STAMP}.sql"
pg_dump --clean --inserts | sed '/EXTENSION/d' > /tmp/${PGDATABASE}_${DATE_STAMP}.sql
echo "Done"

