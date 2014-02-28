#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Description:	Gathering available information about HP Smart Array devices.
# Description:  Analyze information and send data to zabbix server.

PATH="/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin"

hpacucli=$(which hpacucli)
data_tmp="/tmp/hp-raid-data-harvester.tmp"
data_out="/tmp/hp-raid-data-harvester.out"
all_keys='/tmp/keys'
zbx_server=$(grep Server /etc/zabbix/zabbix_agentd.conf |cut -d= -f2 |cut -d, -f1)
zbx_data='/tmp/zabbix-sender-hp-raid-data.in'
ctrl_list=$(${hpacucli} ctrl all show |grep -oE 'Slot [0-9]+' |awk '{print $2}' |xargs echo)

echo -n > $data_tmp

# Get adapters list and get info about each.
echo "### ctrl section begin ###" >> $data_tmp
for slot in $ctrl_list; 
  do
    echo "### ctrl begin $slot ###" >> $data_tmp
    $hpacucli ctrl slot=$slot show >> $data_tmp
    echo "### ctrl end $slot ###" >> $data_tmp
  done
echo "### ctrl section end ###" >> $data_tmp

# enumerate all adapters and all logical drives on each adapter.
echo "### ld section begin ###" >> $data_tmp
for slot in $ctrl_list; 
  do
    ld_list=$($hpacucli ctrl slot=$slot ld all show |grep -w logicaldrive |awk '{print $2}' |xargs echo)
  for ld in $ld_list;
    do
      echo "### ld begin $slot $ld  ###" >> $data_tmp
      $hpacucli ctrl slot=$slot ld $ld show >> $data_tmp
      echo "### ld end $slot $ld ###" >> $data_tmp
    done
  done
echo "### ld section end ###" >> $data_tmp

# enumerate all adapters and all physical drives on each adapter.
echo "### pd section begin ###" >> $data_tmp
for slot in $ctrl_list; 
  do
    pd_list=$($hpacucli ctrl slot=$slot pd all show |grep -w physicaldrive |awk '{print $2}' |xargs echo)
  for pd in $pd_list;
    do
      echo "### pd begin $slot $pd ###" >> $data_tmp
      $hpacucli ctrl slot=$slot pd $pd show >> $data_tmp
      echo "### pd end $slot $pd ###" >> $data_tmp
    done
  done
echo "### pd section end ###" >> $data_tmp

mv $data_tmp $data_out

# fill zabbix key
echo -n > $all_keys
echo -n > $zbx_data

for c in $(/etc/zabbix/scripts/hp-raid-ctrl-discovery.sh raw); 
  do
    echo -n -e "hpraid.ctrl.status[$c]\nhpraid.cache.status[$c]\nhpraid.bbu.status[$c]\n"; 
  done >> $all_keys

for l in $(/etc/zabbix/scripts/hp-raid-ld-discovery.sh raw);
  do
    echo -n -e "hpraid.ld.status[$l]\n";
  done >> $all_keys

for p in $(/etc/zabbix/scripts/hp-raid-pd-discovery.sh raw);
  do
    echo -n -e "hpraid.pd.status[$p]\nhpraid.pd.temperature[$p]\n";
  done >> $all_keys

cat $all_keys | while read key; do
  if [[ "$key" == *hpraid.ctrl.status* ]]; then
     slot=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/ctrl begin $slot/,/ctrl end $slot/p" /tmp/hp-raid-data-harvester.out |grep -wE "[ ]+Controller Status:" |awk '{print $3}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi

  if [[ "$key" == *hpraid.cache.status* ]]; then
     slot=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/ctrl begin $slot/,/ctrl end $slot/p" /tmp/hp-raid-data-harvester.out |grep -wE "[ ]+Cache Status:" |awk '{print $3}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi

  if [[ "$key" == *hpraid.bbu.status* ]]; then
     slot=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d, -f1)
     value=$(sed -n -e "/ctrl begin $slot/,/ctrl end $slot/p" /tmp/hp-raid-data-harvester.out |grep -wE "[ ]+Battery/Capacitor Status:" |awk '{print $3}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi

  if [[ "$key" == *hpraid.ld.status* ]]; then
     slot=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     ld=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2)
     value=$(sed -n -e "/ld begin $slot $ld/,/ld end $slot $ld/p" /tmp/hp-raid-data-harvester.out |grep -wE "[ ]+Status:" |awk '{print $2}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi

  if [[ "$key" == *hpraid.pd.temperature* ]]; then
     slot=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2-)
     value=$(sed -n -e "/pd begin $slot $pd/,/pd end $slot $pd/p" /tmp/hp-raid-data-harvester.out |grep -wE '[ ]+Current Temperature \(C\):' |awk '{print $4}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi

  if [[ "$key" == *hpraid.pd.status* ]]; then
     slot=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f1)
     pd=$(echo $key |grep -o '\[.*\]' |tr -d \[\] |cut -d: -f2-)
     value=$(sed -n -e "/pd begin $slot $pd/,/pd end $slot $pd/p" /tmp/hp-raid-data-harvester.out |grep -wE '[ ]+Status:' |awk '{print $2}')
     echo "$(hostname) $key $value" >> $zbx_data
  fi
  done

# send data to zabbix server
zabbix_sender -z $zbx_server -i $zbx_data &> /dev/null
