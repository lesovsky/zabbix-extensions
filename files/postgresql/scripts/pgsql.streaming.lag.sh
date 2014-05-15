#!/usr/bin/env bash
# Author: Alexey Lesovsky
# Description: Streaming replication lag (run on master).

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из первой строки ~zabbix/.pgpass
if [ "$#" -lt 2 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$2"
fi

replica=$1
query="select round(pg_xlog_location_diff(sent_location, replay_location) /1024 /1024,3) from pg_stat_replication where client_addr = '$replica'"

psql -qAtX -h localhost -U $username $dbname -c "$query"
