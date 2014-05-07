#!/usr/bin/env bash
# Author: Lesovsky A.V.
# Physical drives auto-discovery. VERY VERY EXPERIMENTAL (TESTED ON MEGACLI 8.02.21 Oct 21, 2011)

adp_list=$(sudo megacli adpallinfo aALL nolog |grep "^Adapter #" |cut -d# -f2)
enc_list=$(for a in $adp_list; do sudo megacli encinfo a$a nolog |grep -w "Device ID" |awk '{print $4}'; done)
pd_list=$(for a in $adp_list; 
            do
              for e in $enc_list; 
                do 
                  sudo megacli pdlist a$a nolog |sed -n -e "/Enclosure Device ID: $e/,/Slot Number:/p" |grep -wE 'Slot Number:' |awk -v adp=$a -v enc=$e '{print adp":"enc":"$3}' 
                done
            done)

if [[ $1 = raw ]]; then
  for pd in ${pd_list}; do echo $pd; done ; exit 0
fi

echo -n '{"data":['
for pd in $pd_list; do echo -n "{\"{#PD}\": \"$pd\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
