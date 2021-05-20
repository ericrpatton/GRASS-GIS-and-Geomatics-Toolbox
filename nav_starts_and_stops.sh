#! /bin/bash

INPUT=$1
OUTPUT=$2
LAST=`wc -l ${INPUT} | cut -d' ' -f1`

awk -v INPUT=${INPUT} -v LAST=${LAST} 'BEGIN {printf "%-16s %-9s %-9s %-10s\n", "File", "Time", "Latitude", "Longitude"}
	NR == 1 {print INPUT, $1, $2, $3}
	NR == LAST {print INPUT, $1, $2, $3}' $INPUT >> $OUTPUT

exit 0
