#!/bin/sh
# Author: Alexey Lesovsky
# сбор информации о размере БД

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$1"
fi

psql -qAtX -F: -c "SELECT pg_database_size('$dbname')" -h localhost -U "$username" $(head -n 1 ~zabbix/.pgpass |cut -d: -f3)
