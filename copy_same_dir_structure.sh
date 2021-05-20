#! /bin/bash
#
# A script that copies all directories in the current directory to a
# destination folder. Note that files are not copied, just directory names.
# The user must supply the destination directory name as
# an argument.
#
# Script Created: February 6, 2020
#
##############################################################################

DESTINATION=${1}

for DIR in `ls -1d *` ; do 
	mkdir -pv ${DESTINATION}/${DIR}
done

exit 0
