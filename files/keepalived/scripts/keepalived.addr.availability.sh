#/usr/bin/env bash
# Description:	determines if the IP address is available on this server
# Author:	Lesovsky A.V. <lesovsky@gmail.com>

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
IPADDR=$1

[[ $1 ]] || { echo "ZBX_NOTSUPPORTED, need at least one parameter in which IP address must be specified."; exit 1; }
[[ -f $(which ip 2>/dev/null) ]] || { echo "ZBX_NOTSUPPORTED, ip utility from iproute2 not found."; exit 1; }

if ip addr show |grep -qo $IPADDR; then echo "Up"; else echo "Not present"; fi
