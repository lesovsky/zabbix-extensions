#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Background writer statistics. 
# http://www.postgresql.org/docs/9.3/static/monitoring-stats.html#PG-STAT-BGWRITER-VIEW

[[ -z "$*" ]] && { echo "ZBX_NOTSUPPORTED: specify parameter"; exit 1; }
if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

PARAM="$1"

query="SELECT $PARAM FROM pg_stat_bgwriter"
psql -qAtX -c "$query" -h localhost -U "$username" "$dbname" 2>/dev/null || { echo ZBX_NOTSUPPORTED; exit 1; }
