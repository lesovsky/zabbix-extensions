#!/usr/bin/env bash
# Author: Alexey Lesovsky
# Description: Low level discovery for streaming replication hot-standby servers.

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$2"
fi
PARAM="$1"

if [[ $1 = count ]]; 
  then
    psql -qAtX -h localhost -U $username -tl --dbname=$dbname -c "SELECT count(*) FROM pg_stat_replication"
    exit 0
  else
    replica_list=$(psql -qAtX -h localhost -U $username -tl --dbname=$dbname -c "SELECT client_addr FROM pg_stat_replication")
    echo -n '{"data":['
    for replica in $replica_list; do echo -n "{\"{#HOTSTANDBY}\": \"$replica\"},"; done |sed -e 's:\},$:\}:'
    echo -n ']}'
fi
