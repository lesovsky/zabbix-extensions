#!/usr/bin/env bash
# Description:	check compliance with the current network interface speed to the declared.
# Author:	Lesovsky A.V.	

print_usage() {
        echo "Usage:"
        echo "  ${0##*/} --discovery	discovery ACTIVE physical interfaces"
        echo "  ${0##*/} --check=eth0	check interface speed"
        exit
}

[[ $(which ethtool) ]] || { echo "FATAL: ethtool not found."; exit 1; }
[[ -n $@ ]] || { print_usage; exit 1; }

physIfList=$(find /sys/class/net -type l -not -lname '*virtual*' -printf '%f\n')
physActiveIfList=$(for interface in $physIfList; do 
	[[ -e /sys/class/net/$interface/operstate ]] && echo $interface $(cat /sys/class/net/$interface/operstate); 
done |grep -w up |cut -d' ' -f1)

MODE=$1

case "$MODE" in
'--discovery' )
	printf "{\n";
	printf "\t\"data\":[\n";
	INDEX=0
	for interface in ${physActiveIfList}
	do
		if [ $INDEX -gt 0 ]
		then
			printf ",";
		fi
		printf "\n\t{\n";
		printf "\t\t\"{#PHYS_IFNAME}\":\"$interface\"\n";
		printf "\t},\n";
	done
	printf "\n\t]\n";
	printf "}\n";
	;;
--check=* )
	physIfName=$(echo $1 |cut -d= -f2)
	[[ "$physActiveIfList" == *"$physIfName"* ]] || { echo "FATAL: Interface not found or link not detected. Exit"; exit 1; }

	maxRemoteSupported=$(ethtool $physIfName |sed -n -e '/Advertised link modes:/,/Advertised pause frame use:/p' |grep -oE '[0-9]+' |uniq |sort -n |tail -n1)
	maxLocalSupported=$(ethtool $physIfName |sed -n -e '/Link partner advertised link modes:/,/Link partner advertised pause frame use:/p' |grep -oE '[0-9]+' |uniq |sort -n |tail -n1)
	localCurrent=$(ethtool $physIfName |grep -m1 Speed: |grep -oE '[0-9]+')

	[[ $localCurrent -lt $maxLocalSupported && $localCurrent -lt $maxRemoteSupported ]] && { echo "$physIfName: current interface speed less then supported"; exit 1; }

	echo OK; exit 0 
;;
* ) print_usage;;
esac
