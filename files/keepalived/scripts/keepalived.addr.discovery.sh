#!/usr/bin/env bash
# Description:	keepalived virtual addreses auto-discovery
# Author:	Lesovsky A.V. <lesovsky@gmail.com>

KEEPALIVED_CONF=$1

[[ $1 ]] || { echo "ZBX_NOTSUPPORTED, need at least one parameter in which keepalived.conf must be specified"; exit 1; }
[[ -f $KEEPALIVED_CONF ]] || { echo "ZBX_NOTSUPPORTED, $KEEPALIVED_CONF doesn't exist" ; exit 1; }

ADDRESSES=$(sed -n -e '/virtual_ipaddress {/,/}/p' $KEEPALIVED_CONF |grep -v ^# |grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}*')

printf "{\n";
printf "\t\"data\":[\n\n";

for addr in $ADDRESSES
do
    printf "\t{\n";
    printf "\t\t\"{#KADDR}\":\"$addr\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
