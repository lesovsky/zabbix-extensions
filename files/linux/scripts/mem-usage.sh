#!/usr/bin/env bash
# The aim of this check is detect the moment when memory usage is quite close to critical threshold, 
# when caches are close to be empty and all the memory is used and system starts swapping in near time.

USEDRAM=$(free |grep ^Mem|awk '{print $3}')
USEDSWAP=$(free |grep ^Swap|awk '{print $3}')
FREERAM=$(free |grep ^Mem|awk '{print $4}')
BUFFERS=$(grep ^Buffers: /proc/meminfo |awk '{print $2}')
PAGECACHE=$(grep ^Cached: /proc/meminfo |awk '{print $2}')
TOTALRAM=$(free |grep ^Mem|awk '{print $2}')
USED=$(echo $(($USEDRAM + $USEDSWAP - $FREERAM - $BUFFERS - $PAGECACHE)))

awk "BEGIN {print $USED/$TOTALRAM*100}" |cut -d. -f1
