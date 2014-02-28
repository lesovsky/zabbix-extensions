#!/usr/bin/env bash
# Author: 	Lesovsky A.V.
# Description:	Pgbouncer pools auto-discovery

if [ -f ~/.pgpass ];
then
	username=$(head -n 1 ~/.pgpass |cut -d: -f4);
else
	username="postgres";
fi
config='/etc/pgbouncer/pgbouncer.ini'
hostname=$(grep -w ^listen_addr $config |cut -d" " -f3 |cut -d, -f1)
port=6432
dbname="pgbouncer"

if [ '*' = "$hostname" ]; then hostname="127.0.0.1"; fi

poollist=$(psql -h $hostname -p $port -U $username -ltAF: --dbname=$dbname -c "show pools" |cut -d: -f1 |grep -v ^pgbouncer)

printf "{\n";
printf "\t\"data\":[\n\n";

has_line=0;
for line in ${poollist}
do
	if [ $has_line -eq 1 ];
	then
		printf ",\n";
	fi;
	printf "\t{\n";
    printf "\t\t\"{#POOLNAME}\":\"$line\"\n";
    printf "\t}";
	has_line=1;
done

printf "\n\n\t]\n";
printf "}\n";
