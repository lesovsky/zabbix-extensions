#!/bin/sh
# Author: Alexey Lesovsky
# лаг потоковой репликации БД

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    echo "ZBX_NOTSUPPORTED. uninitialized variable master" ; exit 1;
  else
    master="$1"
fi

dbname=$(grep $master ~zabbix/.pgpass |cut -d: -f3)

s=$(psql -qAtX -h localhost -U $username $dbname -c "select extract(epoch from pg_last_xact_replay_timestamp())" |cut -d. -f1)
now=$(psql -qAtX -h localhost -U $username $dbname -c "select extract(epoch from now())" |cut -d. -f1)

r=$(echo $(( $now - $s )))
if [ "0" -ge "$r" ]; then echo 0; else echo $r; fi
