#! /bin/bash

SCRIPT=$(basename $0)

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT completed_file_format raw_file_format\n"
	exit 1
fi

COMPLETED_FILE_FORMAT=".$1"
RAW_FILE_FORMAT=".$2"

ls -1 *${COMPLETED_FILE_FORMAT} | awk -F'.' '{print $1}' > completed.list
ls -1 *${RAW_FILE_FORMAT} | awk -F'.' '{print $1}' > raw.list

comm -3 completed.list raw.list | awk -v RAW_FILE_FORMAT=${RAW_FILE_FORMAT} '{print $1RAW_FILE_FORMAT}' > process.list

rm completed.list raw.list

exit 0
