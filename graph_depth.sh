#! /bin/bash
#
# graph_depth: This script uses GMT to create a plot of depth vs. time.
# It expects a GMT-style timestamp (eg, 23-Aug-2014T22:10:38.000)
# as the first column, and the depth value as the second.
#
# Last modified: April 21, 2016
#
##############################################################################

INPUT=$1

X_TITLE="Date"
Y_TITLE="Depth (m)"
TITLE="Depth, June - August 2015, Kittigazuit Channel"

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

# Concatenate the time and Depth columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $5}' $INPUT > depth.xy

# Smooth the xy data using median filter
filter1d -f0T -FM1d depth.xy --TIME_UNIT=d -V > depth_filtered.xy 

# Get the max/min extents of the depth file.
GMTINFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd depth_filtered.xy` 

# Parse the min/max extents
WEST=`echo $GMTINFO | awk '{print substr($5,2,19)}'`
EAST=`echo $GMTINFO | awk '{print substr($5,22,19)}'`
SOUTH=`echo $GMTINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
NORTH=`echo $GMTINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

psbasemap -JX9iT/3i -R$WEST/$EAST/$SOUTH/$NORTH -Bsx1O -Bpx7df1d+l"$X_TITLE" -Byaf+l"$Y_TITLE" -BWeSn+t"$TITLE" -K -V > depth.ps

psxy depth_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -V >> depth.ps

# Output section; -Tg gives PNG output, -Te gives EPS output. 
psconvert -A -Tg depth.ps -V -P
psconvert -A -Te depth.ps -V -P

exit 0
