#!/bin/bash
#
#
# grid_each_line.sh - A script to export xyz of each file in an MB-System
# datalist and import into GRASS GIS.
#
#
# Last modified: January 25, 2016
#
#
# CHANGELOG: - Script created (01-25-2016)
#
###############################################################################

# Check to see if GRASS is running; abort if not.
if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT datalist \n"
	exit 1
fi

DATALIST=$1
awk '{print $1}' $DATALIST > LIST.txt
LIST_LENGTH=`cat LIST.txt | wc -l`
COUNTER=1

for FILE in `cat LIST.txt` ; do
	OUTPUT=`echo $FILE | cut -f1 -d'.'`
	XYZ_OUTPUT=${OUTPUT}.xyz
	FORMAT_ID=`mbformat -I $FILE | grep id: | awk -F': ' '{print $2}'`	

	echo -e "\n\n========================================================"
	echo -e "\nWorking on line $FILE (file $COUNTER of $LIST_LENGTH)...please standby.\n"

	mblist -F${FORMAT_ID} -I ${FILE} -D2 | awk '{print $1, $2, -$3}' | proj $(g.proj -jf | sed 's/+type=crs//') | pv | awk '{print $1, $2, $3}' > ${XYZ_OUTPUT}

	import_xyz.sh ${XYZ_OUTPUT}
	r.colors map=${OUTPUT} color=bof_unb --v
	r.csr ${OUTPUT}
	COUNTER=$(($COUNTER + 1))
done

if [ $? -eq 0 ] ; then
	echo -e "\nFinished!"
fi

# CLEANUP
rm LIST.txt

exit 0
