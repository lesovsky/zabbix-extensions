#!/usr/bin/env bash
# Author:       Lesovsky A.V.
# Description:  Gathering available information about MegaCLI supported devices.
# Description:  Analyze information and send data to zabbix server.
# Disclaimer:	VERY VERY EXPERIMENTAL. 

PATH="/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/bin"

megacli=$(which megacli)
data_tmp="/run/megacli-raid-data-harvester.tmp"
data_out="/run/megacli-raid-data-harvester.out"
all_keys='/run/keys'
zbx_server=$(grep Server /etc/zabbix/zabbix_agentd.conf |cut -d= -f2|cut -d, -f1)
zbx_data='/run/zabbix-sender-megacli-raid-data.in'
adp_list=$(/etc/zabbix/scripts/megacli-adp-discovery.sh raw)
ld_list=$(/etc/zabbix/scripts/megacli-ld-discovery.sh raw)
pd_list=$(/etc/zabbix/scripts/megacli-pd-discovery.sh raw)

echo -n > $data_tmp

# берем список контроллеров и берем с каждого информацию.
echo "### adp section begin ###" >> $data_tmp
for adp in $adp_list; 
  do
    echo "### adp begin $adp ###" >> $data_tmp
    $megacli adpallinfo a$adp nolog >> $data_tmp
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
      $megacli ldinfo l$l a$a nolog >> $data_tmp
      echo "### ld end $a $l ###" >> $data_tmp
    done
echo "### ld section end ###" >> $data_tmp

# перебираем все контроллеры и все физические диски на этих контроллерах
echo "### pd section begin ###" >> $data_tmp
for pd in $pd_list;
  do
    a=$(echo $ld|cut -d: -f1)
    e=$(echo $pd|cut -d: -f2)
    p=$(echo $pd|cut -d: -f3)
    echo "### pd begin $a $e $p ###" >> $data_tmp
    $megacli pdinfo physdrv [$e:$p] a$a nolog >> $data_tmp
    echo "### pd end $a $e $p ###" >> $data_tmp
  done
echo "### pd section end ###" >> $data_tmp

mv $data_tmp $data_out

echo -n > $all_keys
echo -n > $zbx_data

# формируем список ключей для zabbix
for a in $adp_list; 
  do
    echo -n -e "megacli.adp.name[$a]\nmegacli.ld.degraded[$a]\nmegacli.ld.offline[$a]\nmegacli.pd.total[$a]\nmegacli.pd.critical[$a]\nmegacli.pd.failed[$a]\nmegacli.mem.err[$a]\nmegacli.mem.unerr[$a]\n"; 
  done >> $all_keys

for l in $ld_list;
  do
    echo -n -e "megacli.ld.state[$l]\n";
  done >> $all_keys

for p in $pd_list;
  do
    echo -n -e "megacli.pd.media_error[$p]\nmegacli.pd.other_error[$p]\nmegacli.pd.pred_failure[$p]\nmegacli.pd.state[$p]\nmegacli.pd.temperature[$p]\n";
  done >> $all_keys

cat $all_keys | while read key; do
  if [[ "$key" == *megacli.adp.name* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -m1 -w "Product Name" |cut -d: -f2)
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.ld.degraded* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -A1 -m1 -w "Virtual Drives" |grep -w "Degraded" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.ld.offline* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -A2 -m1 -w "Virtual Drives" |grep -w "Offline" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.total* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -A1 -m1 -w "Physical Devices" |grep -w "Disks" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.critical* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -A2 -m1 -w "Physical Devices" |grep -w "Critical Disks" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.failed* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -A3 -m1 -w "Physical Devices" |grep -w "Failed Disks" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.mem.err* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -m1 -w "Memory Correctable Errors" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.mem.unerr* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/adp begin $adp/,/adp end $adp/p" $data_out |grep -m1 -w "Memory Uncorrectable Errors" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.ld.state* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     enc=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     value=$(sed -n -e "/ld begin $adp $enc/,/ld end $adp $enc/p" $data_out |grep -m1 -w "^State" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.media_error* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     enc=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f3)
     value=$(sed -n -e "/pd begin $adp $enc $pd/,/ld end $adp $enc $pd/p" $data_out |grep -m1 -w "^Media Error Count:" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.other_error* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     enc=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f3)
     value=$(sed -n -e "/pd begin $adp $enc $pd/,/ld end $adp $enc $pd/p" $data_out |grep -m1 -w "^Other Error Count:" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.pred_failure* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     enc=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f3)
     value=$(sed -n -e "/pd begin $adp $enc $pd/,/ld end $adp $enc $pd/p" $data_out |grep -m1 -w "^Predictive Failure Count:" |cut -d: -f2 |tr -d " ")
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.state* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     enc=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f3)
     value=$(sed -n -e "/pd begin $adp $enc $pd/,/ld end $adp $enc $pd/p" $data_out |grep -m1 -w "^Firmware state:" |cut -d" " -f3 |tr -d ,)
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  if [[ "$key" == *megacli.pd.temperature* ]]; then
     adp=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     enc=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f3)
     value=$(sed -n -e "/pd begin $adp $enc $pd/,/ld end $adp $enc $pd/p" $data_out |grep -m1 -w "^Drive Temperature" |awk '{print $3}' |grep -oE '[0-9]+')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  done

zabbix_sender -z $zbx_server -i $zbx_data &> /dev/null
