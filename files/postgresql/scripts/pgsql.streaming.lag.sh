#!/bin/sh
# Author: Alexey Lesovsky
# лаг потоковой репликации БД

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)
dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3)

r=$(psql -qAtX -h localhost -U $username $dbname -c "select round(extract(epoch from now() - pg_last_xact_replay_timestamp()))")

if [ "0" -ge "$r" ]; then echo 0; else echo $r; fi
