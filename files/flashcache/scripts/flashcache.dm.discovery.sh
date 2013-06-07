#!/usr/bin/env bash
# flashcache volumes auto-discovery

dms=$(for dm in $(sudo dmsetup ls |awk '{print $1}'); do if (sudo dmsetup status $dm |grep flashcache &> /dev/null); then echo $dm; fi; done)

printf "{\n";
printf "\t\"data\":[\n\n";

for dm in ${dms}
do
    printf "\t{\n";
    printf "\t\t\"{#DMNAME}\":\"$dm\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
