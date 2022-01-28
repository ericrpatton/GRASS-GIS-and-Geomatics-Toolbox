#! /bin/bash

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT mbinfo.txt \n"
	exit 1
fi

FILE=$1

cat $FILE | grep "Total Track Length" | awk '{print $4, "km"}'

exit 0
