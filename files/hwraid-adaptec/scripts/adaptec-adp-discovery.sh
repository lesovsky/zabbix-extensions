#!/usr/bin/env bash
# Author: 	Alexey Lesovsky
# Description:	Adaptec adapters auto-discovery via arcconf. (TESTED WITH V5.20 (B17414))

adp_list=$(sudo arcconf getversion |grep -w "^Controller" |cut -d# -f2)

if [[ $1 = raw ]]; then
  for adp in ${adp_list}; do echo $adp; done ; exit 0
fi

echo -n '{"data":['
for adp in $adp_list; do echo -n "{\"{#ADP}\": \"$adp\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
