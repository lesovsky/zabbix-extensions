#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Description:	Logical drives auto-discovery via arcconf. (TESTED WITH V5.20 (B17414))

adp_list=$(sudo arcconf getversion |grep -w "^Controller" |cut -d# -f2)
ld_list=$(for a in $adp_list; do sudo arcconf getconfig $a ld |grep -w "Logical device number" |awk '{print $4}' |while read ld ; do echo $a:$ld; done ; done)

if [[ $1 = raw ]]; then
  for ld in ${ld_list}; do echo $ld; done ; exit 0
fi

printf "{\n";
printf "\t\"data\":[\n\n";

for ld in ${ld_list}
do
    printf "\t{\n";
    printf "\t\t\"{#LD}\":\"$ld\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
