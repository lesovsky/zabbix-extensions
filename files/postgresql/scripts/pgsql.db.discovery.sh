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

dblist=$(psql -h localhost -U $username -tl --dbname=$dbname -c "SELECT datname FROM pg_database WHERE datistemplate IS FALSE AND datallowconn IS TRUE AND datname!='postgres';")

echo -n '{"data":['
for db in $dblist; do echo -n "{\"{#DBNAME}\": \"$db\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
