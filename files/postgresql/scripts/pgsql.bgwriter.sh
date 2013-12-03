#!/bin/sh
# Author: Alexey Lesovsky
# Description: bgwriter statistics. http://www.postgresql.org/docs/9.2/static/monitoring-stats.html#PG-STAT-BGWRITER-VIEW

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ "$#" -lt 2 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$2"
fi
PARAM="$1"

query="SELECT $PARAM FROM pg_stat_bgwriter"

psql -qAtX -c "$query" -h localhost -U "$username" "$dbname" 2>/dev/null || { echo ZBX_NOTSUPPORTED; exit 1; }
