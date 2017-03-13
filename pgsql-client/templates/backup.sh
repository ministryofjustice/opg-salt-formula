#!/usr/bin/env bash

source /root/bashrc
DATESTAMP=`date "+%d%m%Y"`

pgdump --clean --inserts | sed '/EXTENSION/d' > /tmp/${PGDATABASE}_${DATESTAMP}.sql