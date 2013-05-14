#!/bin/sh
# Author: Alexey Lesovsky
# время отклика БД

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$1"
fi

query="select 1;"
echo -e "\\\timing \n select 1" | psql -qAtX -h localhost -U "$username" "$dbname" |grep Time |cut -d' ' -f2
