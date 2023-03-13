#! /bin/bash

SCRIPT=$(basename $0)

if [ "$#" -lt 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT basename_for_renaming [resolution [30]]\n"
	exit 0
fi

BASENAME=$1
RES=$2

[[ -z ${RES} ]] && RES=30

raster_rename_prep.sh "datalistp_${RES}m*"

awk -F, -v basename=$BASENAME 'BEGIN {OFS=","} {print $1, basename"_"$2}' raster_names.csv > tmp && mv tmp raster_names.csv

g.rename.many  raster=raster_names.csv --o 

exit 0
