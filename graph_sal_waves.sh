#! /bin/bash
#
# graph_salwaves.sh: This script uses GMT to create a dual plot of
# salinity and wave height vs. time. The script formats the input files such that
# the first column contains a GMT-style timestamp (eg,
# 23-Aug-2014T22:10:38.000), and the second contains the measured parameter
# (e.g., salinity or wave height).
#
# Last modified: March 4, 2016
#
# CHANGELOG:	- Script created (03-04-2016)
#
##############################################################################

INPUT=$1

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The skip paramter in this script represents the
# number of lines that must skipped to get past the header.
SKIP=$2

if [ -z $SKIP ] ; then
	SKIP=0
fi 

# Concatenate the time and Salinity columns from the input CTD file.
awk -v skip=$SKIP 'NR > skip {print $1"T"$2, $5}' $INPUT > salinity.xy

# Concatenate the time and Temperature columns from the input CTD file.
awk -v skip=$SKIP 'NR > skip {print $1"T"$2, $4}' $INPUT > temperature.xy

# Get the max/min extents of the salinity file.
SALINFO=`gmtinfo -f0T salinity.xy` 
echo $SALINFO

# Get the max/min extents of the temperature file.
TEMPINFO=`gmtinfo -f0T temperature.xy` 
echo $TEMPINFO

# Parse the min/max extents of the salinity file.
# The data will be output so that the format will be yyyy-mm-dd, the 
# datetime format expected by psbasemap.
SALWEST=`echo $SALINFO | awk '{print substr($5,2,19)}'`
SALEAST=`echo $SALINFO | awk '{print substr($5,22,19)}'`
SALSOUTH=`echo $SALINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
SALNORTH=`echo $SALINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo ""
#echo "Salinity file bounds:"
#echo $SALWEST
#echo $SALEAST
#echo $SALSOUTH
#echo $SALNORTH
#echo ""
#exit 0

# Parse the min/max extents of the tempeerature file.
TEMPWEST=`echo $TEMPINFO | awk '{print substr($5,2,19)}'`
TEMPEAST=`echo $TEMPINFO | awk '{print substr($5,22,19)}'`
TEMPSOUTH=`echo $TEMPINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
TEMPNORTH=`echo $TEMPINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo "Temperature file bounds:"
#echo $TEMPWEST
#echo $TEMPEAST
#echo $TEMPSOUTH
#echo $TEMPNORTH
#echo ""
#exit 0

# KLUGE
#SALNORTH=15


# Smooth the graphs using filter1d

filter1d -f0T -Fm1d salinity.xy --TIME_UNIT=d -V > salinity_filtered.xy 
filter1d -f0T -Fc1d temperature.xy --TIME_UNIT=d -V > temperature_filtered.xy 

psbasemap -JX9.5iT/3.5i -R"$SALWEST/$SALEAST/$SALSOUTH/$SALNORTH" -Bsx1Y -Bpx1O+l"Date" -Byaf+l"Salinity (ppt)" -BWSn+t"Salinity vs. Temperature, East Channel, Tuktoyaktuk, NWT 2014-2015" -K -V > saltemp.ps

psbasemap -J -R$TEMPWEST/$TEMPEAST/$TEMPSOUTH/$TEMPNORTH -Bsx1Y -Bpxa1Od -Byaf+l"Temperature in \260 C" -BE  -O -K -V >> saltemp.ps 

# Plot salinity
#psxy salinity.xy -f0T -J -R -Wblack -O -K -V >> saltemp.ps
psxy salinity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> saltemp.ps

# Plot temperature
#psxy temperature.xy -f0T -J -R -Wthinnest,gray65 -O -K -V >> saltemp.ps
psxy temperature_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> saltemp.ps

# Plot legend
pslegend -Dx7.5i/2.5i/1.4i/BL -J -F -O << EOF >> saltemp.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Salinity 
S 0.1i - 0.2i - 2p,blue 0.3i Temperature 
G 0.1i
EOF

# Plot output
psconvert -Tg saltemp.ps -V -A
psconvert -Te saltemp.ps -V -A

exit 0
