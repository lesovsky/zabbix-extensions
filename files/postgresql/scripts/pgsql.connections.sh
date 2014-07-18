#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Get current connections information
# http://www.postgresql.org/docs/9.3/static/monitoring-stats.html#PG-STAT-ACTIVITY-VIEW

[[ -z "$*" ]] && { echo "ZBX_NOTSUPPORTED: specify parameter"; exit 1; }
if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

PARAM="$1"

case "$PARAM" in
'idle_in_transaction' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction';"
;;
'idle' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle';"
;;
'total' )
        query="SELECT COUNT(*) FROM pg_stat_activity;"
;;
'active' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active';"
;;
'waiting' )
        query="SELECT COUNT(*) FROM pg_stat_activity WHERE waiting <> 'f';"
;;
'total_pct' )
        query="select count(*)*100/(select current_setting('max_connections')::int) from pg_stat_activity;"
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

psql -qAtX -F: -c "$query" -h localhost -U "$username" "$dbname"
