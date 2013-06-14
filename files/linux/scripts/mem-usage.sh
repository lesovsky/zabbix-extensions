#!/usr/bin/env bash
# суть проверки выяснить момент когда использование памяти подходит к критической границе 
# когда кэши невозможно занять, память заполнена и система вот-вот начнет реально свопиться.

USEDRAM=$(free |grep ^Mem|awk '{print $3}')
USEDSWAP=$(free |grep ^Swap|awk '{print $3}')
FREERAM=$(free |grep ^Mem|awk '{print $4}')
BUFFERS=$(grep ^Buffers: /proc/meminfo |awk '{print $2}')
PAGECACHE=$(grep ^Cached: /proc/meminfo |awk '{print $2}')
TOTALRAM=$(free |grep ^Mem|awk '{print $2}')
USED=$(echo $(($USEDRAM + $USEDSWAP - $FREERAM - $BUFFERS - $PAGECACHE)))

awk "BEGIN {print $USED/$TOTALRAM*100}" |cut -d. -f1
