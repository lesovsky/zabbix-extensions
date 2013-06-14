#!/usr/bin/env bash
if [ $(id -u) -ne 0 ]; then echo "Warning: need root privileges."; exit 1; fi

if [ $(which zabbix-sender) ]
  then echo "Info: zabbix-sender found." 
  else echo "Warning: zabbix-sender not found in PATH. Exit."; exit 1
fi
if [ $(which hpacucli) ]
  then echo "Info: hpacucli found."
  else echo "Warning: hpacucli not found in PATH. Exit."; exit 1
fi

if [ ! -d /etc/zabbix/scripts ]; then
  mkdir -p /etc/zabbix/scripts
  cp -v ./scripts/*sh /etc/zabbix/scripts/
fi

if [ ! -d /etc/zabbix/zabbix_agentd.d ]; then
  mkdir -p /etc/zabbix/zabbix_agentd.d
  cp -v ./*.conf /etc/zabbix/zabbix_agentd.d/
fi

chown zabbix: /etc/zabbix/scripts/ -R
chown zabbix: /etc/zabbix/zabbix_agentd.d/ -R
chmod 755 /etc/zabbix/scripts/*.sh

echo "Info: edit zabbix_agentd configuration."
echo 'Include=/etc/zabbix/zabbix_agentd.d/' >> /etc/zabbix/zabbix_agentd.conf
echo "Info: add task into root crontab."
(crontab -l; echo "*/10    *       *       *       *       /etc/zabbix/scripts/hp-raid-data-processor.sh") |uniq - |crontab -
echo "Finish: perform zabbix_agentd service restart for activate changes."
