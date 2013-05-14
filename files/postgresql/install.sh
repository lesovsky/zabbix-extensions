#!/usr/bin/env bash
if [ $(id -u) -ne 0 ]; then echo "Warning: need root privileges."; exit 1; fi

if [ ! -d /etc/zabbix/scripts ]; then
  mkdir -p /etc/zabbix/scripts
  cp -v ./scripts/*.sh /etc/zabbix/scripts/
fi

chown zabbix: /etc/zabbix/scripts/pgsql.*.sh
chmod 755 /etc/zabbix/scripts/pgsql.*.sh

echo "INFO: set ~zabbix/.pgpass auth parameters."
