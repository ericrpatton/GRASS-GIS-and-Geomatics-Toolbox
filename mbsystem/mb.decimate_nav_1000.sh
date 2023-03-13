#! /bin/bash

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT datalist.mb-1\n"
	exit 0
fi

DATALIST=$1

[[ -z ${DATALIST} ]] && DATALIST=datalist.mb-1

mblist -F-1 -I ${DATALIST} -OXYJ -K1000 | pv | awk '{print $1, $2, $3, $4, $5, $6, $7}' > Nav_decimated_1000th.txt

exit 0
