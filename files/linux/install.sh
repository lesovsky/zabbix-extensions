#!/usr/bin/env bash
if [ $(id -u) -ne 0 ]; then echo "Warning: need root privileges."; exit 1; fi

if [ $(which zabbix-sender) ]
  then echo "Info: zabbix-sender found." 
  else echo "Warning: zabbix-sender not found in PATH. Exit."; exit 1
fi

if [ ! -d /etc/zabbix/scripts ]; then
  mkdir -p /etc/zabbix/scripts
  cp -v ./scripts/*.sh /etc/zabbix/scripts/
fi

chown zabbix: /etc/zabbix/scripts/*.sh
chmod 755 /etc/zabbix/scripts/*.sh

echo "Info: add task into root crontab."
(crontab -l; echo "0 */2 * * * /usr/libexec/zabbix-extensions/scripts/check-open-descriptors.sh") |uniq - |crontab -
