#! /bin/bash
#
# graph_salinity: This script uses GMT to create a plot of salinity vs. time.
# It expects a GMT-style timestamp (eg, 23-Aug-2014T22:10:38.000)
# as the first column, and the salinity value as the second.
#
# Last modified: January 30, 2016
#
# CHANGELOG: - Improved header (01-29-2016)
#			 - Added headskip and tailskip parameters that allow omitting bad
#			 sections of the input file at the beginning or end of the file,
#			 respectively (01-30-2016)
#			 - Changed psbasemap code so that y-axis frame annotations are
#			 calculated automatically (01-30-2016)
#
##############################################################################

INPUT=$1

X_TITLE="Date"
Y_TITLE="Salinity (ppt)"
TITLE="Salinity, June - August 2015, Kittigazuit MID EWF-HI"

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of the file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
HEADSKIP=$2
TAILSKIP=$3

if [ -z $HEADSKIP ] ; then
	HEADSKIP=0
fi 

if [ -z $TAILSKIP ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	TAILSKIP=`wc -l $INPUT | awk '{print $1}'`
fi 

# Concatenate the time and Salinity columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $8}' $INPUT > salinity.xy

# Smooth the xy data using median filter
#filter1d -f0T -FM1d salinity.xy --TIME_UNIT=d -V > salinity_filtered.xy 

# Get the max/min extents of the salinity file.
#GMTINFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd salinity_filtered.xy` 
GMTINFO=`gmtinfo -f0T salinity.xy` 
#echo $GMTINFO
#exit 0

# Parse the min/max extents
WEST=`echo $GMTINFO | awk '{print substr($5,2,19)}'`
EAST=`echo $GMTINFO | awk '{print substr($5,22,19)}'`
SOUTH=`echo $GMTINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
NORTH=`echo $GMTINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo ""
#echo "West is $WEST"
#echo "East is $EAST"
#echo "South is $SOUTH"
#echo "North is $NORTH"
#echo""
#exit 0

psbasemap -JX9iT/3i -R$WEST/$EAST/$SOUTH/$NORTH -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y_TITLE" -BWeSn+t"$TITLE" -K -V > salinity.ps

#psxy salinity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> salinity.ps
psxy salinity.xy -f0T -J -R -Wthinner,orange -O -V >> salinity.ps

# Output section; -Tg gives PNG output, -Te gives EPS output. 
psconvert -A -Tg salinity.ps -V -P
psconvert -A -Te salinity.ps -V -P

exit 0
