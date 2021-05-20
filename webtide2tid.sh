#! /bin/bash
#
# A quick hack to format the output from the CHS WebTide program to CARIS HIPS
# .tid format.
#

TIDEFILE=$1 

awk '{print $4"/"$5, $6, $7, $1}' $TIDEFILE | awk '{printf "%s %02d %s %02d %1.4f\n", $1,  $2, ":", $3, $4}' > temp.txt
awk '{print $1, $2$3$4, $5}' temp.txt > `basename $TIDEFILE .txt`.tid

rm temp.txt

exit 0
