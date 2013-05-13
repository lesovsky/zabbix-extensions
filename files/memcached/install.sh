#!/usr/bin/env bash
if [ $(id -u) -ne 0 ]; then echo "Warning: need root privileges."; exit 1; fi

if [ ! -d /etc/zabbix/zabbix-agentd.d ]; then
  mkdir -p /etc/zabbix/zabbix-agentd.d
  cp -v ./memcached.conf /etc/zabbix/zabbix-agentd.d/
fi

chown zabbix: /etc/zabbix/zabbix-agentd.d/memcached.conf
