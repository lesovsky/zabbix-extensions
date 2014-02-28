#!/usr/bin/env bash
# Author:       Lesovsky A.V.
# Descriprion:  Low-level discovery for HP Smart Array physical drives

data="/tmp/hp-raid-data-harvester.out"

if [ -f $data ]; then
  pd_list=$(sed -n -e '/pd section begin/,/pd section end/p' $data |grep -w 'pd begin' |awk '{OFS=":"} {print $4,$5}')
  else echo "$data not found."; exit 1
fi

if [[ $1 = raw ]]; then
  for line in ${pd_list}; do echo $line; done ; exit 0
fi

printf "{\n";
printf "\t\"data\":[\n\n";

has_line=0;
for line in ${pd_list}
do
	if [ $has_line -eq 1 ];
	then
		printf ",\n";
	fi;
    printf "\t{\n";
    printf "\t\t\"{#PD}\":\"$line\"\n";
    printf "\t}";
	has_line=1;
done

printf "\n\n\t]\n";
printf "}\n";
