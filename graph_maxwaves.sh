#! /bin/bash
#
# graph_maxdepth.sh: This script uses GMT to create a plot of maxdepth vs.
# time.  It expects a GMT-style timestamp (eg, 23-Aug-2014T22:10:38.000) as
# the first column, and the maxdepth value as the second.
#
# Last modified: March 3, 2016
#
# CHANGELOG: - Script created (03-03-2016)
#
##############################################################################

INPUT=$1

X_TITLE="Date"
Y_TITLE="Maximum wave height in XX"
TITLE="Max Wave Height, June-August 2015, Kittigazuit MID EWF-HI, NWT."

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of the file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
HEADSKIP=$2
TAILSKIP=$3

if [ -z $TAILSKIP ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	TAILSKIP=`wc -l $INPUT | awk '{print $1}'`
fi 

# Concatenate the time and Salinity columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $9}' $INPUT > maxwaves.xy

# Smooth the xy data using median filter
filter1d -f0T -FM1d maxwaves.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > maxwaves_filtered.xy 

# Get the max/min extents of the depth file.
DEPTHINFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd --TIME_UNIT=d maxwaves_filtered.xy` 

# Parse the min/max extents of the depth file.
DEPTHWEST=`echo $DEPTHINFO | awk '{print substr($5,2,19)}'`
DEPTHEAST=`echo $DEPTHINFO | awk '{print substr($5,22,19)}'`
DEPTHSOUTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
DEPTHNORTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo "Depthwest is $DEPTHWEST."
#echo "Deptheast is $DEPTHEAST."
#echo "Depthsouth is $DEPTHSOUTH."
#echo "Depthnorth is $DEPTHNORTH."
#echo ""
#exit 0

psbasemap -JX9iT/3i -R$DEPTHWEST/$DEPTHEAST/$DEPTHSOUTH/$DEPTHNORTH -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y_TITLE" -BWeSn+t"$TITLE" -K -V > maxwaves.ps

psxy maxwaves_filtered.xy  -J -R -f0T --FORMAT_DATE_IN=yyyy-mm-dd -Wthin,red -O -V >> maxwaves.ps

# Output section
psconvert -Tg maxwaves.ps -A -V -P
psconvert -Te maxwaves.ps -A -V -P

exit 0
