#!/usr/bin/env bash
# Author: 	Lesovsky A.V.
# Description:	queue and consumers info
# $1 - queue name, $2 - param

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

case "$PARAM" in
'length' )
        q="select pending_events from pgq.get_consumer_info() where queue_name = '$1'"
;;
'lag' )
        q="select extract(epoch from lag) from pgq.get_consumer_info() where queue_name = '$1'"
;;
'last_seen' )
        q="select extract(epoch from last_seen) from pgq.get_consumer_info() where queue_name = '$1'"
;;
'ev_per_sec' )
        q="select ev_per_sec from pgq.get_queue_info() where queue_name = '$1'"
;;
* ) echo ZBX_NOTSUPPORTED; exit 1;;
esac

r=$(psql -h localhost -p 5432 -tA -U "$username" "$dbname" -c "$q" |head -n 1)
[[ -z "$r" ]] && echo 0 || echo $r
