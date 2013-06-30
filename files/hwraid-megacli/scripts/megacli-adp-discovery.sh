#!/usr/bin/env bash
# Author: Alexey Lesovsky
# Adapters auto-discovery via MegaCLI. VERY VERY EXPERIMENTAL (TESTED WITH 8.02.21 Oct 21, 2011)

adp_list=$(sudo megacli adpallinfo aALL nolog |grep "^Adapter #" |cut -d# -f2)

if [[ $1 = raw ]]; then
  for adp in ${adp_list}; do echo $adp; done ; exit 0
fi

printf "{\n";
printf "\t\"data\":[\n\n";

for adp in ${adp_list}
do
    printf "\t{\n";
    printf "\t\t\"{#ADPNUM}\":\"$adp\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
