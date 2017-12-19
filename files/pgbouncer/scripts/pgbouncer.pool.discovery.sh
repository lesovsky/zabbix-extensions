#!/usr/bin/env bash
# Author: 	Lesovsky A.V.
# Description:	Pgbouncer pools auto-discovery

if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi

hostname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f1)
port=$(head -n 1 ~zabbix/.pgpass |cut -d: -f2)
username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)
dbname="pgbouncer"

if [ '*' = "$hostname" ]; then hostname="127.0.0.1"; fi

poollist=$(psql -h $hostname -p $port -U $username -ltAF: --dbname=$dbname -c "show pools" |cut -d: -f1,2 |grep -v ^pgbouncer)

echo -n '{"data":['
for pool in $poollist; do echo -n "{\"{#POOLNAME}\": \"$pool\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
