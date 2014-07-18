#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Get size of specified database

[[ -z "$*" ]] && { echo "ZBX_NOTSUPPORTED: specify parameter"; exit 1; }
if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

PARAM="$1"

psql -qAtX -F: -h localhost -U $username $dbname -c "SELECT pg_database_size('$PARAM')"
