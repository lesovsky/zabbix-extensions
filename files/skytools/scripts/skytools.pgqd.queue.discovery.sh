#!/usr/bin/env bash
# Author: Alexey Lesovsky
# автопоиск очередей pgq

username=$(head -n 1 ~zabbix/.pgpass |cut -d: -f4)

#если имя базы не получено от сервера, то имя берется из ~zabbix/.pgpass
if [ -z "$*" ]; 
  then 
    if [ ! -f ~zabbix/.pgpass ]; then echo "ERROR: ~zabbix/.pgpass not found" ; exit 1; fi
    dbname=$(head -n 1 ~zabbix/.pgpass |cut -d: -f3);
  else
    dbname="$1"
fi

queuelist=$(psql -qAtX -h localhost -U $username $dbname -c "select pgq.get_queue_info()" |cut -d, -f1 |tr -d \()


printf "{\n";
printf "\t\"data\":[\n\n";

for queue in ${queuelist}
do
    printf "\t{\n";
    printf "\t\t\"{#QNAME}\":\"$queue\"\n";
    printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
