#!/usr/bin/env bash
# Author: 	Alexey Lesovsky
# Description:	Adaptec adapters auto-discovery via arcconf. (TESTED WITH V5.20 (B17414))

adp_list=$(sudo arcconf getversion |grep -w "^Controller" |cut -d# -f2)

if [[ $1 = raw ]]; then
  for adp in ${adp_list}; do echo $adp; done ; exit 0
fi

printf "{\n";
printf "\t\"data\":[\n\n";

for adp in ${adp_list}
do
    printf "\t{\n";
    printf "\t\t\"{#ADP}\":\"$adp\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
