#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Description:	Glusterfs mounts auto-discovery

mountpoints=$(egrep -e '\sglusterfs\s' /etc/fstab|grep -v ^# |awk '{print $2}')

echo -n '{"data":['
for mount in $mountpoints; do echo -n "{\"{#MOUNT}\": \"$mount\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
