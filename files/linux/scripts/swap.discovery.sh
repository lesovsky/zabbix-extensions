#!/usr/bin/env bash
# Author:	Lesovsky A.V.
# Description:	Swap discovery

SIZE=$(swapon -s |grep -v ^Filename |awk '{sum += $3} END {print sum}')

if [ -z $SIZE ]; then exit 1; fi

echo -n '{"data":['
echo -n "{\"{#SWAP_EXISTS}\": \"$line\"}";
echo -n ']}'
