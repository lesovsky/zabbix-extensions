#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Check trigger existance

if [ -z "$*" ]; then echo "ZBX_NOTSUPPORTED"; exit 1; fi
username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

# get database name from zabbix server, otherwise from ~zabbix/.pgpass
if [ "$#" -lt 2 ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$2"
fi

PARAM=$1

psql -qAtX -h localhost -U "$username" "$dbname" -c "select count(*) from pg_trigger where tgenabled='O' and tgname='$PARAM'"
