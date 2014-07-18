#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Get longest transaction activity
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
'idle' )
        query="SELECT COALESCE(EXTRACT (EPOCH FROM MAX(age(NOW(), query_start))), 0) as d FROM pg_stat_activity WHERE state='idle in transaction';"
;;
'active' )
	query="SELECT COALESCE(EXTRACT (EPOCH FROM MAX(age(NOW(), query_start))), 0) as d FROM pg_stat_activity WHERE state <> 'idle in transaction' AND state <> 'idle'"
;;
'waiting' )
	query="SELECT COALESCE(EXTRACT (EPOCH FROM MAX(age(NOW(), query_start))), 0) as d FROM pg_stat_activity WHERE waiting = 't'"
;;
'pending_xa_count' )
	query="SELECT count(*) FROM pg_prepared_xacts where COALESCE(EXTRACT (EPOCH FROM age(NOW(), prepared)), 0) > 1000;"
;;
'pending_xa_max_time' )
	query="SELECT COALESCE(EXTRACT (EPOCH FROM max(age(NOW(), prepared))), 0) as d FROM pg_prepared_xacts;"
;;
'*' ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

psql -qAtX -h localhost -U "$username" "$dbname" -c "$query"
