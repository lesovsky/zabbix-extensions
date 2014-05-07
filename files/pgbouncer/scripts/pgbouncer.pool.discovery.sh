#!/usr/bin/env bash
# Author: 	Lesovsky A.V.
# Description:	Pgbouncer pools auto-discovery

if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
config='/etc/pgbouncer.ini'
hostname=$(grep -w ^listen_addr $config |cut -d" " -f3 |cut -d, -f1)
port=6432
dbname="pgbouncer"
username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

if [ '*' = "$hostname" ]; then hostname="127.0.0.1"; fi

poollist=$(psql -h $hostname -p $port -U $username -ltAF: --dbname=$dbname -c "show pools" |cut -d: -f1 |grep -v ^pgbouncer)

echo -n '{"data":['
for pool in $poollist; do echo -n "{\"{#POOLNAME}\": \"$pool\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
