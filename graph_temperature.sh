#! /bin/bash
#
# graph_temperature.sh: This script uses GMT to create a plot of temperature
# vs. time. It expects a GMT-style timestamp (eg, 23-Aug-2014T22:10:38.000) as
# the first column, and the temperature value as the second.
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
Y_TITLE="Temperature (\260C)"
TITLE="Temperature, June - August 2015, Kittigazuit Channel"

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

# Concatenate the time and temperature columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $3}' $INPUT > temperature.xy

# For files that contain simply time and temperature columns; comment out as
# needed:
#awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $4}' $INPUT > temperature.xy

# Smooth the xy data using median filter
#filter1d -f0T -FM1d temperature.xy --TIME_UNIT=d -V > temperature_filtered.xy 
filter1d -f0T -FM1d temperature.xy --FORMAT_DATE_IN=dd-o-yyyy --TIME_UNIT=d -V > temperature_filtered.xy 

# Get the max/min extents of the temperature file.
GMTINFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd temperature_filtered.xy` 

echo $GMTINFO
# Parse the min/max extents
WEST=`echo $GMTINFO | awk '{print substr($5,2,19)}'`
EAST=`echo $GMTINFO | awk '{print substr($5,22,18)}'`
SOUTH=`echo $GMTINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
NORTH=`echo $GMTINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo ""
echo "Temperature file bounds:"
echo $WEST
echo $EAST
echo $SOUTH
echo $NORTH
echo ""
#exit 0

psbasemap -JX9iT/3i -R$WEST/$EAST/$SOUTH/$NORTH -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y_TITLE" -BWeSn+t"$TITLE" -K -V > temperature.ps

psxy temperature_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -V >> temperature.ps
#psxy temperature.xy -f0T -J -R -Wthinner,blue -O -V >> temperature.ps

# Output section; -Tg gives PNG output, -Te gives EPS output. 
psconvert -A -Tg temperature.ps -V -P
psconvert -A -Te temperature.ps -V -P

exit 0
