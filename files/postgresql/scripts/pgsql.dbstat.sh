#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Get database-wide statistics
# http://www.postgresql.org/docs/9.3/static/monitoring-stats.html#PG-STAT-DATABASE-VIEW

[[ -z "$*" ]] && { echo "ZBX_NOTSUPPORTED: specify parameter"; exit 1; }
if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

PARAM="$1"
TARGETDB="$2"

query_substr="SELECT SUM($PARAM) FROM pg_stat_database"

if [ -z "$2" ];
  then
    query="$query_substr"
  else
    query="$query_substr WHERE datname = '$TARGETDB'"
fi

psql -qAtX -h localhost -U "$username" "$dbname" -c "$query" || { echo "ZBX_NOTSUPPORTED"; exit 1; }
