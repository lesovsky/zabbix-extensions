#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Databases low level discovery

if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

dblist=$(psql -h localhost -U $username -tl --dbname=$dbname -c "SELECT datname FROM pg_database WHERE datistemplate IS FALSE AND datallowconn IS TRUE AND datname!='postgres';")

echo -n '{"data":['
for db in $dblist; do echo -n "{\"{#DBNAME}\": \"$db\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
