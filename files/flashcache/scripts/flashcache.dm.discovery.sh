#!/usr/bin/env bash
# Author:	Lesovsky A.V. <lesovsky@gmail.com>
# Description:	Flashcache volumes auto-discovery

dms=$(for dm in $(sudo dmsetup ls |awk '{print $1}'); do if (sudo dmsetup status $dm |grep flashcache &> /dev/null); then echo $dm; fi; done)

echo -n '{"data":['
for dm in $dms; do echo -n "{\"{#DMNAME}\": \"$dm\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
