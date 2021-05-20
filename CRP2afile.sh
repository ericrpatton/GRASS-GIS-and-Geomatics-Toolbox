#! /bin/bash

# An ugly hack to chop up navigation from Peter's Master Logger and extract out
# the corrected CRP position (stern of Hudson) to assign nav for Huntec and
# Airguns.
#
# The output from this script is suitable for use as input to the script
# v.in.afile
##############################################################################

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

INPUT=$1
OUTPUT="CRPlocation_nav_10sec.txt"

echo -e "\nExtracting CRP location nav; please standby...\n"

awk -F'|' '/CRP/ {print $5, $6}' ${INPUT} | sed 's/[TZ]/ /g' \
| awk '{print $1substr($2,1,2)substr($2,4,2)substr($2,7,2), substr($4,2,9), "-"substr($5,3,9)}' \
| uniq -w16 | sed -e 's/^2018-08-17/229/' -e 's/^2018-08-18/230/' -e 's/^2018-08-19/231/' -e 's/^2018-08-20/232/' -e 's/^2018-08-21/233/' \
-e 's/^2018-08-22/234/' -e 's/^2018-08-23/235/' -e 's/^2018-08-24/236/' -e 's/^2018-08-25/237/' \
-e 's/^2018-08-26/238/' -e 's/^2018-08-27/239/' -e 's/^2018-08-28/240/' \
-e 's/^2018-08-29/241/' -e 's/^2018-08-30/242/' -e 's/^2018-08-31/243/' \
-e 's/^2018-09-01/244/' -e 's/^2018-09-02/245/' -e 's/^2018-09-03/246/' \
-e 's/^2018-09-04/247/' -e 's/^2018-09-05/248/' -e 's/^2018-09-06/249/' \
-e 's/^2018-09-07/250/' -e 's/^2018-09-08/251/' | awk '$1 % 10 == 0 {print $1, $2, $3}' > ${OUTPUT}

if [ -f ${OUTPUT} ] ; then
	echo "Done."
fi

exit 0 
