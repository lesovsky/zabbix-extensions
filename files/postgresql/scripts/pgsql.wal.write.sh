#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации об интенсивности записи WAL-журналов

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ "$#" -lt 2 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$2"
fi

POS=$(psql -qAtX -c "select pg_xlogfile_name(pg_current_xlog_location())" -h localhost -U "$username" "$dbname" | cut -b 9-16,23-24)

echo $((0x$POS))
