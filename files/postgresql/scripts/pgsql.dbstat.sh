#!/bin/sh
# Author: Alexey Lesovsky
# сбор статистики работа БД
# Standard Statistics Views - pg_stat_database

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из первой строки ~zabbix/.pgpass
if [ "$#" -lt 2 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$2"
fi
PARAM="$1"

case "$PARAM" in
'blks_hit' )
        query_substr="SELECT SUM(blks_hit) FROM pg_stat_database"
;;
'blks_read' )
        query_substr="SELECT SUM(blks_read) FROM pg_stat_database"
;;
'commits' )
        query_substr="SELECT SUM(xact_commit) FROM pg_stat_database"
;;
'rollbacks' )
        query_substr="SELECT SUM(xact_rollback) FROM pg_stat_database"
;;
'tup_deleted' )
        query_substr="SELECT SUM(tup_deleted) FROM pg_stat_database"
;;
'tup_inserted' )
        query_substr="SELECT SUM(tup_inserted) FROM pg_stat_database"
;;
'tup_fetched' )
        query_substr="SELECT SUM(tup_fetched) FROM pg_stat_database"
;;
'tup_updated' )
        query_substr="SELECT SUM(tup_updated) FROM pg_stat_database"
;;
'tup_returned' )
        query_substr="SELECT SUM(tup_returned) FROM pg_stat_database"
;;
'temp_files' )
        query_substr="SELECT SUM(temp_files) FROM pg_stat_database"
;;
'temp_bytes' )
        query_substr="SELECT SUM(temp_bytes) FROM pg_stat_database"
;;
'deadlocks' )
        query_substr="SELECT SUM(deadlocks) FROM pg_stat_database"
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

if [ -z "$2" ];
  then
    query="$query_substr"
  else
    query="$query_substr WHERE datname = '$dbname'"
fi

psql -qAtX -F: -c "$query" -h localhost -U "$username" "$dbname"
