#!/usr/bin/env bash
# Author:       Lesovsky A.V. <lesovsky@gmail.com>
# Description:	Flashcache volumes auto-discovery

if [ ! -d /proc/flashcache ]; then exit 1; fi

volumes=$(ls -1d /proc/flashcache/*/ 2> /dev/null |cut -d\/ -f4)

printf "{\n";
printf "\t\"data\":[\n\n";

for vol in ${volumes}
do
    printf "\t{\n";
    printf "\t\t\"{#VOLNAME}\":\"$vol\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
