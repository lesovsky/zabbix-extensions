#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Description:	Glusterfs mounts auto-discovery

mountpoints=$(grep glusterfs /etc/fstab |grep -v ^# |awk '{print $2}')

printf "{\n";
printf "\t\"data\":[\n\n";

for mount in ${mountpoints}
do
    printf "\t{\n";
    printf "\t\t\"{#MOUNT}\":\"$mount\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
