#!/usr/bin/env bash
# Author:   Lesovsky A.V.
# Description:  Get values stored in Redis keys

getValues=$(redis-cli --raw $1 $2)

printf "{\n";
printf "\t\"data\":[\n\n";

for value in ${getValues}
do
  printf "\t{\n";
  printf "\t\t\"{#VALUE}\":\"$value\"\n";
  printf "\t},\n";
done

printf "\n\t]\n";
printf "}\n";
