#!/usr/bin/env bash
# Author:       Lesovsky A.V.
# Descriprion:  Low-level discovery for HP Smart Array logical volumes

data="/tmp/hp-raid-data-harvester.out"

if [ -f $data ]; then
  ld_list=$(sed -n -e '/ld section begin/,/ld section end/p' $data |grep -w 'ld begin' |awk '{OFS=":"} {print $4,$5}')
  else echo "$data not found."; exit 1
fi

if [[ $1 = raw ]]; then
  for line in ${ld_list}; do echo $line; done ; exit 0
fi

echo -n '{"data":['
for ld in $ld_list; do echo -n "{\"{#LD}\": \"$ld\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
