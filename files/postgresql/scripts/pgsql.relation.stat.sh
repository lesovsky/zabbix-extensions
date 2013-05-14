#!/bin/sh
# Author: Alexey Lesovsky
# сбор статистики по определнной таблице
# Standard Statistics Views - pg_stat_user_tables, pg_statio_user_tables
# первым параметр - имя таблицы
# второй параметр - параметр статистики
# третий парамтер (опц.) - имя базы

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ "$#" -lt 3 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$3"
fi
# определяем какую харакетристику будем искать
PARAM="$2"

# Если имя таблицы задано в формате схема.таблица, разделяем имя таблицы 
# Если схема не указана то определяем схему как public
if [[ "$1" =~ "." ]] 
  then 
    SCHEMA=$(echo "$1" |cut -d. -f1)
    RELATION=$(echo "$1" |cut -d. -f2)
  else
    RELATION="$1"
    SCHEMA=public
fi

case "$PARAM" in
'heapread' )
	q="SELECT heap_blks_read FROM pg_statio_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'heaphits' )
	q="SELECT heap_blks_hit FROM pg_statio_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'idxread' )
	q="SELECT idx_blks_read FROM pg_statio_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'idxhits' )
	q="SELECT idx_blks_hit FROM pg_statio_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'toastread' )
	q="SELECT toast_blks_read FROM pg_statio_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'toasthits' )
	q="SELECT toast_blks_read FROM pg_statio_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'seqscan' )
	q="SELECT seq_scan FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'seqread' )
	q="SELECT seq_tup_read FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'idxscan' )
	q="SELECT idx_scan FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'idxfetch' )
	q="SELECT idx_tup_fetch FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'inserted' )
	q="SELECT n_tup_ins FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'updated' )
	q="SELECT n_tup_upd FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'deleted' )
	q="SELECT n_tup_del FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'hotupdated' )
	q="SELECT n_tup_hot_upd FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'live' )
	q="SELECT n_live_tup FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
'dead' )
	q="SELECT n_dead_tup FROM pg_stat_user_tables WHERE relname = '$RELATION' and schemaname = '$SCHEMA'"
;;
* ) exit 1;;
esac

echo $q |psql -h localhost -p 5432 -tA -U "$username" "$dbname"
