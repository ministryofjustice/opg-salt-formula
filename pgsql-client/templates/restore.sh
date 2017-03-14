#!/usr/bin/env bash

set -o allexport
. /root/.bash_profile
export PGPASSFILE=/root/.pgpass
set +o allexport

while getopts ":f:d:" opt; do
  case $opt in
    f) FILE_NAME="$OPTARG"
    ;;
    d) DATE_STAMP="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ "${DATE_STAMP}x" == "x" ];
then
    DATE_STAMP=`date "+%d%m%Y"`
fi

if [ "${FILE_NAME}x" == "x" ];
then
    FILE_NAME="${PGDATABASE}_${DATE_STAMP}.sql"
fi

date
echo "Restoring from backup in /tmp/${FILE_NAME}"
psql --quiet < /tmp/${FILE_NAME}
echo "Done"
