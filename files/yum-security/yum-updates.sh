#!/bin/bash

YUM_RESULT=/tmp/yum-security.out
ZBX_DATA=/tmp/zabbix-sender-yum-data.in
TOTAL_UPDATES=$(yum check-update -q --errorlevel=0 |wc -l)
ZBX_SERVER=$(grep Server /etc/zabbix/zabbix_agentd.conf |cut -d= -f2)

yum list-security -q --errorlevel=0 |awk '{print $2}' |sort |uniq -c > /tmp/yum-bugs

low=$(grep 'Low/Sec.' /tmp/yum-bugs |awk '{print $1}')
moderate=$(grep 'Moderate/Sec.' /tmp/yum-bugs |awk '{print $1}')
important=$(grep 'Important/Sec.' /tmp/yum-bugs |awk '{print $1}')
critical=$(grep 'Critical/Sec.' /tmp/yum-bugs |awk '{print $1}')
enhancement=$(grep 'enhancement' /tmp/yum-bugs |awk '{print $1}')
bugfix=$(grep 'bugfix' /tmp/yum-bugs |awk '{print $1}')

if [ -z $low ]; then low=0; fi
if [ -z $moderate ]; then moderate=0; fi
if [ -z $important ]; then important=0; fi
if [ -z $critical ]; then critical=0; fi
if [ -z $enhancement ]; then enhancement=0; fi
if [ -z $bugfix ]; then bugfix=0; fi

echo -n > $ZBX_DATA
echo "$(hostname) rh.updates.enh $enhancement" >> $ZBX_DATA
echo "$(hostname) rh.updates.bugfix $bugfix" >> $ZBX_DATA
echo "$(hostname) rh.updates.low $low" >> $ZBX_DATA
echo "$(hostname) rh.updates.mod $moderate" >> $ZBX_DATA
echo "$(hostname) rh.updates.imp $important" >> $ZBX_DATA
echo "$(hostname) rh.updates.crit $critical" >> $ZBX_DATA
echo "$(hostname) rh.updates.total $TOTAL_UPDATES" >> $ZBX_DATA

zabbix_sender -z $ZBX_SERVER -i $ZBX_DATA &> /dev/null
