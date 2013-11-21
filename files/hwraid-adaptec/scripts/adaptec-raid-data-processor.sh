#!/usr/bin/env bash
# Author:       Lesovsky A.V.
# Description:  Gathering available information about MegaCLI supported devices.
# Description:  Analyze information and send data to zabbix server.

PATH="/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/bin"

arcconf=$(which arcconf)
data_tmp="/run/adaptec-raid-data-harvester.tmp"
data_out="/run/adaptec-raid-data-harvester.out"
all_keys='/run/keys'
zbx_server=$(grep Server /etc/zabbix/zabbix_agentd.conf |cut -d= -f2|cut -d, -f1)
zbx_data='/run/zabbix-sender-adaptec-raid-data.in'
adp_list=$(/usr/libexec/zabbix-extensions/scripts/adaptec-adp-discovery.sh raw)
ld_list=$(/usr/libexec/zabbix-extensions/scripts/adaptec-ld-discovery.sh raw)
pd_list=$(/usr/libexec/zabbix-extensions/scripts/adaptec-pd-discovery.sh raw)

echo -n > $data_tmp

# берем список контроллеров и берем с каждого информацию.
echo "### adp section begin ###" >> $data_tmp
for adp in $adp_list; 
  do
    echo "### adp begin $adp ###" >> $data_tmp
    $arcconf getconfig $adp ad >> $data_tmp
    echo "### adp end $adp ###" >> $data_tmp
  done
echo "### adp section end ###" >> $data_tmp

# перебираем все контроллеры и все логические тома на этих контроллерах
echo "### ld section begin ###" >> $data_tmp
for ld in $ld_list;
  do
    a=$(echo $ld|cut -d: -f1)
    l=$(echo $ld|cut -d: -f2)
    echo "### ld begin $a $l  ###" >> $data_tmp
    $arcconf getconfig $a ld $l >> $data_tmp
    echo "### ld end $a $l ###" >> $data_tmp
  done
echo "### ld section end ###" >> $data_tmp

# перебираем все контроллеры и все физические диски на этих контроллерах
echo "### pd section begin ###" >> $data_tmp
for pd in $pd_list;
  do
    a=$(echo $ld|cut -d: -f1)
    p=$(echo $pd|cut -d: -f2)
    echo "### pd begin $a $p ###" >> $data_tmp
    $arcconf getconfig $a pd >> $data_tmp
    echo "### pd end $a $p ###" >> $data_tmp
  done
echo "### pd section end ###" >> $data_tmp

mv $data_tmp $data_out

echo -n > $all_keys
echo -n > $zbx_data

# формируем список ключей для zabbix
for a in $adp_list; 
  do
    echo -n -e "adaptec.adp.status[$a]\nadaptec.adp.name[$a]\nadaptec.adp.temp[$a]\nadaptec.adp.ld_total[$a]\nadaptec.adp.ld_failed[$a]\nadaptec.adp.ld_degraded[$a]\nadaptec.bbu.status[$a]\n"; 
  done >> $all_keys

for l in $ld_list;
  do
    echo -n -e "adaptec.ld.status[$l]\n";
  done >> $all_keys

for p in $pd_list;
  do
    echo -n -e "adaptec.pd.status[$p]\n";
  done >> $all_keys

cat $all_keys | while read key; do
  if [[ "$key" == *adaptec.adp.status* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\])
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -w "Controller Status" |awk '{print $4}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.adp.name* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\])
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -w "Controller Model" |awk -F: '{print $2}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.adp.temp* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\])
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -wE "[ ]+Temperature[ ]+" |awk '{print $3}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.adp.ld_total* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\])
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -w "Logical devices/Failed/Degraded" |cut -d: -f2 |tr -d ' ' |cut -d/ -f1)
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.adp.ld_failed* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\])
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -w "Logical devices/Failed/Degraded" |cut -d: -f2 |tr -d ' ' |cut -d/ -f2)
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.adp.ld_degraded* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\])
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -w "Logical devices/Failed/Degraded" |cut -d: -f2 |tr -d ' ' |cut -d/ -f3)
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.bbu.status* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\])
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |sed -n -e '/Controller Battery Information/,/Status/p' |grep -w Status |cut -d: -f2 |tr -d ' ')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.ld.status* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     ld=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     value=$(sed -n -e "/ld begin $adp $ld/,/ld end $adp $ld/p" $data_out |grep -w "Status of logical device" |cut -d: -f2 |tr -d ' ')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *adaptec.pd.status* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     value=$(sed -n -e "/pd begin $adp $pd/,/ld end $adp $pd/p" $data_out |sed -n -e "/Device #$pd/,/Device #/p" |grep -m1 -wE '[ ]+State[ ]+' |cut -d: -f2 |tr -d ' ')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
done

zabbix_sender -z $zbx_server -i $zbx_data &> /dev/null
