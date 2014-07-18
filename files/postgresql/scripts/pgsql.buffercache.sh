#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Allow examining what's happening in the shared buffer cache in real time.
# http://www.postgresql.org/docs/9.3/static/pgbuffercache.html

[[ -z "$*" ]] && { echo "ZBX_NOTSUPPORTED: specify parameter"; exit 1; }
if [[ -f ~zabbix/.pgpass ]]
  then
    username=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f4)
    dbname=$(head -n 1 ~zabbix/.pgpass 2>/dev/null |cut -d: -f3)
fi
dbname=${dbname:-postgres}
username=${username:-postgres}

PARAM="$1"

case "$PARAM" in
'clear' )
        query="SELECT COUNT(*) FROM pg_buffercache WHERE isdirty='f';"
;;
'dirty' )
        query="SELECT COUNT(*) FROM pg_buffercache WHERE isdirty='t';"
;;
'used' )
        query="SELECT COUNT(*) FROM pg_buffercache WHERE reldatabase IS NOT NULL;"
;;
'total' )
        query="SELECT count(*) FROM pg_buffercache;"
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

psql -qAtX -F: -c "$query" -h localhost -U "$username" "$dbname"
