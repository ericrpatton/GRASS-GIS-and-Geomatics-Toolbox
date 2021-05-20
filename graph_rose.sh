#! /bin/bash
#
# graph_rose.sh: This script uses GMT to create a rose diagram for ADCP
# current data, extracting velocity and azimuth pairs from the input file
# at each depth, and outputs these as indivіdual rose diagrams.
#
# Last modified: April 20, 2016
#
# CHANGELOG: - Script created (03-18-2016)
#
##############################################################################

# The input expected is a csv file containing current velocity and azimuth
# pairs at each depth throughout the water column.

INPUT=$1

echo -e "\nExtracting velocity,azimuth pairs from input file $INPUT...please standby.\n"

# Create a text file of velocity,azimuth pairs at each depth interval
for STEP in `seq 10 2 40` ; do
	DEPTH=`awk -F';' -v STEP=${STEP} 'NR == 1 {print $STEP}' ${INPUT} | cut -d'(' -f2 | sed 's/)//'`
	OUTTEXT=`basename ${INPUT} .csv`_${DEPTH}.txt

	echo -e "\tWriting interval ${STEP}m to $(($STEP + 1))m..."
	awk -F';' -v STEP=$STEP 'NR > 1 {print $STEP, $(STEP+1)}' ${INPUT} | awk '{print $1, $2}' > ${OUTTEXT}
done

# Concatenate all the text files in order to calculate the minimum and
# maximum range of velocity values
cat ${OUTTEXT} >> TEMP.txt
MIN=`gmtinfo TEMP.txt | awk '{print $5}' | cut -d'/' -f1 | sed 's/<//'`
MAX=`gmtinfo TEMP.txt | awk '{print $5}' | cut -d'/' -f2 | sed 's/>//'`

echo -e "\nThe caluclated min and max of all files is $MIN to $MAX...\n"
sleep 1.25

# Loop through all text files and create scetor diagrams
for FILE in `basename $INPUT .csv`*m.txt ; do

	#echo "Using a min of $MIN and a max of $MAX."
	DEPTH="`basename $FILE .txt | awk -F'_' '{print $2}'`"
	LOCATION="Tuk ADCP Deployment"
	DATE="June - August, 2015"
	TITLE="Sector Diagram for $LOCATION at $DEPTH, $DATE"
	OUTPS=`basename $FILE .txt`.ps

	psrose ${FILE} -R0/1/0/360 -Bx0.3g0.3 -By30g30 -B+t"${TITLE}" -V -Glightblue -F -A0 -M5p+e+gblue+pthinner -D -Sn5c -L270/90/180/0 -W0.5p,black --FONT_LABEL=8p --FONT_TITLE=10p > ${OUTPS}

	psconvert -A -V -Tj -P ${OUTPS}
	echo ""
done

rm TEMP.txt
exit 0
