#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Added:	04-12-2013
# Issue:	http://next.jira.fun-box.ru/browse/TS-58
# Descriprion:	Low-level discovery for HP Smart Array controllers

data="/tmp/hp-raid-data-harvester.out"

if [ -f "$data" ]; then
  ctrl_list=$(sed -n -e '/ctrl section begin/,/ctrl section end/p' $data |grep -oE 'Slot [0-9]+' |awk '{print $2}')
  else echo "$data not found."; exit 1
fi

if [ $1 = raw ]; then
  for line in ${ctrl_list}; do echo $line; done ; exit 0
fi

printf "{\n";
printf "\t\"data\":[\n\n";

for line in ${ctrl_list}
do
    printf "\t{\n";
    printf "\t\t\"{#CTRL_SLOT}\":\"$line\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
