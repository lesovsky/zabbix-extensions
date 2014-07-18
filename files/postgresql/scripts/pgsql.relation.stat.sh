#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Get table statistics
# http://www.postgresql.org/docs/9.3/static/monitoring-stats.html#PG-STAT-ALL-TABLES-VIEW
# http://www.postgresql.org/docs/9.3/static/monitoring-stats.html#PG-STATIO-ALL-TABLES-VIEW
# $1 - tablename; $2 - stat parameter; $3 - database name (optional)

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

# get database name from zabbix server, otherwise from ~zabbix/.pgpass
if [ "$#" -lt 3 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$3"
fi

PARAM="$2"

# default search_path is public
if [[ "$1" =~ "." ]] 
  then 
    SCHEMA=$(echo "$1" |cut -d. -f1)
    RELATION=$(echo "$1" |cut -d. -f2)
  else
    RELATION="$1"
    SCHEMA=public
fi

[[ "$PARAM" =~ ((heap|idx|toast|tidx)_blks_(read|hit)) ]] && statView="pg_statio_user_tables" || statView="pg_stat_user_tables"

query="SELECT COALESCE($PARAM::text, '0') FROM $statView WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"

psql -qAtX -h localhost -U "$username" "$dbname" -c "$query" || { echo ZBX_NOTSUPPORTED; exit 1; }
