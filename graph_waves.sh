#! /bin/bash

INPUT=$1

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The skip paramter in this script represents the
# number of lines that must skipped to get past the header.
SKIP=$2

if [ -z $SKIP ] ; then
	SKIP=0
fi 

# Concatenate the time and Depth columns from the input CTD file.
awk -v skip=$SKIP 'NR > skip {print $1"T"$2, $5}' $INPUT > depth.xy

# Get the max/min extents of the depth file.
DEPTHINFO=`gmtinfo -f0T depth.xy` 

# Parse the min/max extents of the depth file.
DEPTHWEST=`echo $DEPTHINFO | awk '{print substr($5,2,19)}'`
DEPTHEAST=`echo $DEPTHINFO | awk '{print substr($5,21,19)}'`
DEPTHSOUTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
DEPTHNORTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

psbasemap -JX9i/3i -R$DEPTHWEST/$DEPTHEAST/$DEPTHSOUTH/$DEPTHNORTH -Bsx1Y -Bpx1O+l"Date" -Bya5f2+l"Depth in XX" -BWeSn+t"Depth, June - August 2015, Kittigazuit MID EWF-HI, NWT." -K -V > depth.ps

psxy depth.xy -J -R -Wthin,red -O -V >> depth.ps

psconvert -Tg depth.ps -V -A -P 
psconvert -Te depth.ps -V -A -P

exit 0
