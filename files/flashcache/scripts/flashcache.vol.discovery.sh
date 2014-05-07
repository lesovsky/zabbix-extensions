#!/usr/bin/env bash
# Author:       Lesovsky A.V. <lesovsky@gmail.com>
# Description:	Flashcache volumes auto-discovery

if [ ! -d /proc/flashcache ]; then exit 1; fi

volumes=$(ls -1d /proc/flashcache/*/ 2> /dev/null |cut -d\/ -f4)

echo -n '{"data":['
for vol in $volumes; do echo -n "{\"{#VOLNAME}\": \"$vol\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'
