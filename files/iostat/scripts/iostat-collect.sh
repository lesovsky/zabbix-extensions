#!/usr/bin/env bash
# Description:	Script for iostat monitoring
# Author:	Epikhin Mikhail michael@nomanlab.org
# Revision 1:	Lesovsky A.V. lesovsky@gmail.com

SECONDS=$2
TOFILE=$1
IOSTAT="/usr/bin/iostat"

[[ $# -lt 2 ]] && { echo "FATAL: some parameters not specified"; exit 1; }

DISK=$($IOSTAT -x 1 $SECONDS | awk 'BEGIN {check=0;} {if(check==1 && $1=="avg-cpu:"){check=0}if(check==1 && $1!=""){print $0}if($1=="Device:"){check=1}}' | tr '\n' '|')
echo $DISK | sed 's/|/\n/g' > $TOFILE
echo 0
