#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Descriprion:	Low-level discovery for HP Smart Array controllers

data="/tmp/hp-raid-data-harvester.out"

if [ -f "$data" ]; then
  ctrl_list=$(sed -n -e '/ctrl section begin/,/ctrl section end/p' $data |grep -oE 'Slot [0-9]+' |awk '{print $2}')
  else echo "$data not found."; exit 1
fi

if [[ $1 = raw ]]; then
  for line in ${ctrl_list}; do echo $line; done ; exit 0
fi

printf "{\n";
printf "\t\"data\":[\n\n";

has_line=0;
for line in ${ctrl_list}
do
	if [ $has_line -eq 1 ];
	then
		printf ",\n";
	fi;
    printf "\t{\n";
    printf "\t\t\"{#CTRL_SLOT}\":\"$line\"\n";
    printf "\t}";
	has_line=1;
done

printf "\n\n\t]\n";
printf "}\n";
