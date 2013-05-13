#!/usr/bin/env bash
if [ $(id -u) -ne 0 ]; then echo "Warning: need root privileges."; exit 1; fi

if [ $(which zabbix-sender) ]
  then echo "Info: zabbix-sender found." 
  else echo "Warning: zabbix-sender not found in PATH. Exit."; exit 1
fi

if [ ! -d /etc/zabbix/zabbix-agentd.d ]; then
  mkdir -p /etc/zabbix/zabbix-agentd.d
  cp -v ./redis.conf /etc/zabbix/zabbix-agentd.d/
fi

chown zabbix: /etc/zabbix/zabbix-agentd.d/redis.conf
