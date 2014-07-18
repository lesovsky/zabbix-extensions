#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Streaming replication lag with specified stand-by (run on master).

[[ -z "$*" ]] && { echo "ZBX_NOTSUPPORTED: specify parameter"; exit 1; }
if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

replica=$1
query="select round(pg_xlog_location_diff(sent_location, replay_location) /1024 /1024,3) from pg_stat_replication where client_addr = '$replica'"

psql -qAtX -h localhost -U $username $dbname -c "$query"
