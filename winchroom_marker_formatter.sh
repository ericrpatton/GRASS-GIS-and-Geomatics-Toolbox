#! /bin/bash
#
# winchroom_marker_formatter.sh
#
# A script to format the garbage output from the Hudson winch roon Aldebaran
# markers to human-readable format.
#
# Creation Date: August, 31, 2018
#
##############################################################################

INPUT=$1
OUTPUT="`basename $INPUT .txt`_formatted.txt"

sed 's/\?\*\?\^#\(\)/;/g' ${INPUT} | sed 's/\?\*//g' | sed 's/()//g' > ${OUTPUT}

exit 0
