#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Description:	Swap discovery

SIZE=$(swapon -s |grep -v ^Filename |awk '{sum += $3} END {print sum}')

if [ -z $SIZE ]; then exit 1; fi

printf "{\n";
printf "\t\"data\":[\n\n";

printf "\t{\n";
printf "\t\t\"{#SWAP_EXISTS}\":\"$line\"\n";
printf "\t},\n";

printf "\n\t]\n";
printf "}\n";
