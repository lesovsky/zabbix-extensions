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

echo $(( \
	$(printf "%d\n" "0x"$(psql -qAtX -h $master -U $username $dbname -c "SELECT pg_current_xlog_location()" |cut -d\/ -f2)) \
	- \
	$(printf "%d\n" "0x"$(psql -qAtX -h localhost -U $username $dbname -c "SELECT pg_last_xlog_replay_location()" |cut -d\/ -f2)) \
      ))
