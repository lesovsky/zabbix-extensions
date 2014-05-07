#!/usr/bin/env bash
# Author: 	Lesovsky A.V.
# Description:	PGQ queues auto-discovery

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$1"
fi

queuelist=$(psql -qAtX -h localhost -U $username $dbname -c "select pgq.get_queue_info()" |cut -d, -f1 |tr -d \()

echo -n '{"data":['
for queue in $queuelist; do echo -n "{\"{#QNAME}\": \"$queue\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
