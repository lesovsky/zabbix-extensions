#!/bin/sh
# Author: Alexey Lesovsky
# подсчет количества строк в таблице
# $1 - таблица $2 - бд

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ "$#" -lt 2 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$2"
fi

if [ -z "$*" ]; then echo "ZBX_NOTSUPPORTED"; exit 1; fi

psql -qAtX -h localhost -U "$username" "$dbname" -c "SELECT count(*) from $1"
