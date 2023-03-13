#! /bin/bash

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT number_of_random_files_needed [20]"
	echo -e "Createѕ a user-provided number of texfiles containing random data to the current directory (defaults to 20 files if no number is given).\n"
	exit 0
fi

NEEDED_FILES=$1

if [[ -z ${NEEDED_FILES} ]] ; then NEEDED_FILES=20 ; fi

for FILE in $(seq 1 ${NEEDED_FILES}) ; do head -c 1M < /dev/urandom > ${FILE}.txt; done

exit 0 
