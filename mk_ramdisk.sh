#! /bin/bash

SIZE=$1

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT filesize_to_use \n"
	exit 1
fi

# If no SIZE parameter is given, assign a default size of 8GB.
[[ -z $SIZE ]] && SIZE=8192

# Create the default destination folder if it does not already exist.
[[ ! -d /home/epatton/ram ]] && mkdir /home/epatton/ram
sudo mount -t tmpfs tmpfs /home/epatton/ram -o size=${SIZE}
sudo chown epatton ram
sudo chgrp epatton ram

exit 0
