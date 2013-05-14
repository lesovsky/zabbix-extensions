#!/usr/bin/env bash
if [ $(id -u) -ne 0 ]; then echo "Warning: need root privileges."; exit 1; fi

if [ ! -d /etc/zabbix/scripts ]; then
  mkdir -p /etc/zabbix/scripts
  cp -v ./scripts/pgbouncer.*.sh /etc/zabbix/scripts/
fi

if [ ! -d /etc/zabbix/zabbix_agentd.d ]; then
  mkdir -p /etc/zabbix/zabbix_agentd.d
  cp -v ./pgbouncer.conf /etc/zabbix/zabbix_agentd.d/
fi

chown zabbix: /etc/zabbix/scripts/pgbouncer.*.sh
chown zabbix: /etc/zabbix/zabbix_agentd.d/pgbouncer.conf
chmod 755 /etc/zabbix/scripts/pgbouncer.*.sh
chmod 644 /etc/zabbix/zabbix_agentd.d/pgbouncer.conf

echo "INFO: set ~zabbix/.pgpass auth parameters."
