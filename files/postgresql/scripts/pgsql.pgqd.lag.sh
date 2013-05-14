#!/bin/sh
# Author: Alexey Lesovsky
# вывод лага для указанной очереди pgqd (только Skytools 3).

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ "$#" -lt 2 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
    queue_name="$1"
  else
    dbname="$1"
    queue_name="$2"
fi

if [ -z "$*" ]; then echo "ZBX_NOTSUPPORTED"; exit 1; fi

psql -qAtX -h localhost -U "$username" "$dbname" -c "select round from monitor.pgq_lag where queue_name = '$queue_name';"
