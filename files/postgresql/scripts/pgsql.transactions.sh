#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации о транзакциях
# первый параметр - статус транзакции, второй - имя базы (опциональный)

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

psql -qAtX -F: -c "$query" -h localhost -U "$username" "$dbname"
