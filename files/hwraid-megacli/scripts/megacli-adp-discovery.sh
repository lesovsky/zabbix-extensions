#!/usr/bin/env bash
# Author: Lesovsky A.V.
# Adapters auto-discovery via MegaCLI. VERY VERY EXPERIMENTAL (TESTED WITH 8.02.21 Oct 21, 2011)

adp_list=$(sudo megacli adpallinfo aALL nolog |grep "^Adapter #" |cut -d# -f2)

if [[ $1 = raw ]]; then
  for adp in ${adp_list}; do echo $adp; done ; exit 0
fi

echo -n '{"data":['
for adp in $adp_list; do echo -n "{\"{#ADPNUM}\": \"$adp\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
