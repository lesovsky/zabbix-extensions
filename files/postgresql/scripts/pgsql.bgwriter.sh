#!/usr/bin/env bash
# Description: bgwriter statistics. http://www.postgresql.org/docs/9.2/static/monitoring-stats.html#PG-STAT-BGWRITER-VIEW

[[ -f ~zabbix/.pgpass ]] || { echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; }
username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)
dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3)
PARAM="$1"

query="SELECT $PARAM FROM pg_stat_bgwriter"
psql -qAtX -c "$query" -h localhost -U "$username" "$dbname" 2>/dev/null || { echo ZBX_NOTSUPPORTED; exit 1; }
