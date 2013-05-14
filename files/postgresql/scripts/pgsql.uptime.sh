#!/bin/sh
# Author: Alexey Lesovsky
# время работы БД с момента запуска

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)
dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);

psql -qAtX -h localhost -U "$username" "$dbname" -c "select date_part('epoch', now() - pg_postmaster_start_time())::int;"
