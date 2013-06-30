#!/bin/bash
# Author:	Lesovsky A.V.
# Description:  Search open handlers deleted files and output file size associated with the handler.

LSOF=$(which lsof)
ZBX_SERVER=$(grep -w ^Server /etc/zabbix/zabbix_agentd.conf |cut -d= -f2 |cut -d, -f1)

for mount in $(cat /proc/mounts |grep -wE 'ext[2-4]+|xfs' |awk '{print $2}');
  do
    LOCAL_BIG=$($LSOF $mount |grep -i del |awk '{print $7}' |sort -n |tail -n1)
    if [ ! -z "$LOCAL_BIG" ] && [[ $LOCAL_BIG -ge $GLOBAL_BIG ]]; then GLOBAL_BIG=$LOCAL_BIG ; else GLOBAL_BIG=0; fi
  done

zabbix_sender -z $ZBX_SERVER -s $(hostname) -k system.deleted_filehandler_maxsize -o "$GLOBAL_BIG"
