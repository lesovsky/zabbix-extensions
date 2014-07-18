#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Transaction ID Wraparound information
# http://www.postgresql.org/docs/9.3/interactive/routine-vacuuming.html

if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

query="SELECT freez,txns,ROUND(100*(txns/freez::float)) AS perc,datname \
	FROM \
	( SELECT foo.freez::int,age(datfrozenxid) AS txns,datname \
		FROM pg_database d JOIN \
		( SELECT setting AS freez FROM pg_settings WHERE name = 'autovacuum_freeze_max_age') AS foo ON (true) \
		WHERE d.datallowconn \
	) AS foo2 WHERE datname = '$dbname' \
ORDER BY 3 DESC, 4 ASC"

psql -qAtX -F: -c "$query" -h localhost -U "$username" "$dbname" |cut -d: -f3
