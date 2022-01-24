#! /bin/bash

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT grass_program_name \n"
	exit 1
fi

INPUT=$1
grass --tmp-location EPSG:4326 --exec ${INPUT} --help

exit 0
