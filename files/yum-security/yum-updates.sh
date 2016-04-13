#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Description:	yum updates info

YUM_LOG=/var/log/yum-updates.log

# Clean up cache & reload to prevent metadata issues
yum clean all -q 2>&1 >> $YUM_LOG
yum makecache -q 2>&1 >> $YUM_LOG

YUM_RESULT=/tmp/yum-security.out
ZBX_DATA=/tmp/zabbix-sender-yum-data.in
TOTAL_UPDATES=$(yum check-update -q --errorlevel=0 |wc -l)

sleep 3

ZBX_HOSTNAME_PRESENT=$(egrep ^Hostname /etc/zabbix/zabbix_agentd.conf -c)
if [ "$ZBX_HOSTNAME_PRESENT" -ge "1" ]; then
	ZBX_HOSTNAME=$(egrep ^Hostname /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
else
	ZBX_HOSTNAME=$(hostname)
fi

yum list-security -q --errorlevel=0 |awk '{print $2}' |sort |uniq -c > $YUM_RESULT

low=$(grep 'low/Sec.' $YUM_RESULT |awk '{print $1}')
moderate=$(grep 'moderate/Sec.' $YUM_RESULT |awk '{print $1}')
important=$(grep 'important/Sec.' $YUM_RESULT |awk '{print $1}')
critical=$(grep 'critical/Sec.' $YUM_RESULT |awk '{print $1}')
enhancement=$(grep 'enhancement' $YUM_RESULT |awk '{print $1}')
bugfix=$(grep 'bugfix' $YUM_RESULT |awk '{print $1}')

[[ ! $low ]] && low=0
[[ ! $moderate ]] && moderate=0
[[ ! $important ]] && important=0
[[ ! $critical ]] && critical=0
[[ ! $enhancement ]] && enhancement=0
[[ ! $bugfix ]] && bugfix=0

echo -n > $ZBX_DATA
echo "${ZBX_HOSTNAME} rh.updates.enh $enhancement" >> $ZBX_DATA
echo "${ZBX_HOSTNAME} rh.updates.bugfix $bugfix" >> $ZBX_DATA
echo "${ZBX_HOSTNAME} rh.updates.low $low" >> $ZBX_DATA
echo "${ZBX_HOSTNAME} rh.updates.mod $moderate" >> $ZBX_DATA
echo "${ZBX_HOSTNAME} rh.updates.imp $important" >> $ZBX_DATA
echo "${ZBX_HOSTNAME} rh.updates.crit $critical" >> $ZBX_DATA
echo "${ZBX_HOSTNAME} rh.updates.total $TOTAL_UPDATES" >> $ZBX_DATA

#zabbix_sender -z $ZBX_SERVER -i $ZBX_DATA &>> /var/log/yum-updates.log
zabbix_sender -vv -c /etc/zabbix/zabbix_agentd.conf --tls-connect psk --tls-psk-file /etc/zabbix/zabbix-agent.psk --tls-psk-identity AGENT-PSK-001   -i $ZBX_DATA &>> $YUM_LOG
ZBX_RESULT=`echo $?`

rm $YUM_RESULT
rm $ZBX_DATA

echo $ZBX_RESULT
