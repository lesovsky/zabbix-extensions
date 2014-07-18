#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	WAL write amount and WAL segments count

if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

PARAM=$1

case "$PARAM" in
'write' )
  POS=$(psql -qAtX -c "select pg_xlogfile_name(pg_current_xlog_location())" -h localhost -U "$username" "$dbname" | cut -b 9-16,23-24)
  echo $((0x$POS))
;;
'count' )
  psql -qAtX -h localhost -U "$username" "$dbname" -c "select count(*) from pg_ls_dir('pg_xlog')"
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac
