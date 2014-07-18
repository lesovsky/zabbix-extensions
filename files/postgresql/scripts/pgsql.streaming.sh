#!/usr/bin/env bash
# Author:	Lesovsky A.V., lesovsky@gmail.com
# Description:	Low level discovery and count for streaming replication hot-standby servers.

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
'count' )
	psql -qAtX -h localhost -U $username $dbname -c "SELECT count(*) FROM pg_stat_replication" || { echo "ZBX_NOTSUPPORTED"; exit 1; }
;;
'state' )
	psql -qAtX -h localhost -U $username $dbname -c "SELECT pg_is_in_recovery()"
;;
'discovery' )
	replica_list=$(psql -qAtX -h localhost -U $username $dbname -c "SELECT client_addr FROM pg_stat_replication")
	echo -n '{"data":['
	for replica in $replica_list; do echo -n "{\"{#HOTSTANDBY}\": \"$replica\"},"; done |sed -e 's:\},$:\}:'
	echo -n ']}'
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1 ;;
esac
