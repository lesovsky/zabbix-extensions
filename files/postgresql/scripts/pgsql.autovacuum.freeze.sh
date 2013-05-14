#!/bin/sh
# Author: Alexey Lesovsky
# Details http://www.postgresql.org/docs/9.0/interactive/routine-vacuuming.html
# 23.1.4. Preventing Transaction ID Wraparound Failures

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$1"
fi

query="SELECT freez,txns,ROUND(100*(txns/freez::float)) AS perc,datname \
	FROM \
	( SELECT foo.freez::int,age(datfrozenxid) AS txns,datname \
		FROM pg_database d JOIN \
		( SELECT setting AS freez FROM pg_settings WHERE name = 'autovacuum_freeze_max_age') AS foo ON (true) \
		WHERE d.datallowconn \
	) AS foo2 WHERE datname = '$dbname' \
ORDER BY 3 DESC, 4 ASC"

psql -qAtX -F: -c "$query" -h localhost -U "$username" "$dbname" |cut -d: -f3
