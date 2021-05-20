#! /bin/bash
#
# graph_temp_depth.sh: This script uses GMT to create a dual plot of depth
# and temperature vs. time. The script formats the input files such that the first
# column contains a GMT-style timestamp (eg, 23-Aug-2014T22:10:38.000), and
# the second contains the measured parameter (e.g., depth or sailinty).
#
# NOTE: This script expects both the temp and depth values to come from the
# waves.txt file; you will need to edit the input file and the columns that
# are used for these parameters if different input is used.
#
# Last modified: April 21, 2016
#
##############################################################################

INPUT=$1

X_TITLE="Date"
Y1_TITLE="Depth (m)"
Y2_TITLE="Temperature (\260C)"
TITLE="Depth vs. Temperature, June - August 2015, Kittigazuit Channel, NWT."

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

# Concatenate the time and temperature columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $3}' $INPUT > temperature.xy

# Concatenate the time and depth columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $5}' $INPUT > depth.xy

# Smooth the xy data using median filter
filter1d -f0T -FM1d temperature.xy --TIME_UNIT=d -V > temperature_filtered.xy 
filter1d -f0T -FM1d depth.xy --TIME_UNIT=d -V > depth_filtered.xy 

# Get the max/min extents of the depth file.
DEPTHINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T depth_filtered.xy` 
echo $DEPTHINFO

# Get the max/min extents of the temperature file.
TEMPINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T temperature_filtered.xy` 
echo $TEMPINFO

# Parse the min/max extents of the depth file.
# The data will be output so that the format will be yyyy-mm-dd, the 
# datetime format expected by psbasemap.
DEPTHWEST=`echo $DEPTHINFO | awk '{print substr($5,2,19)}'`
DEPTHEAST=`echo $DEPTHINFO | awk '{print substr($5,22,19)}'`
DEPTHSOUTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
DEPTHNORTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo "DEPTHWEST is $DEPTHWEST"
#echo "DEPTHEAST IS $DEPTHEAST"
#echo "DEPTHSOUTH is $DEPTHSOUTH"
#echo "DEPTHNORTH IS $DEPTHNORTH"
#echo ""

# Parse the min/max extents of the tempeerature file.
TEMPWEST=`echo $TEMPINFO | awk '{print substr($5,2,19)}'`
TEMPEAST=`echo $TEMPINFO | awk '{print substr($5,22,19)}'`
TEMPSOUTH=`echo $TEMPINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
TEMPNORTH=`echo $TEMPINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo "TEMPWEST is $TEMPWEST"
#echo "TEMPEAST IS $TEMPEAST"
#echo "TEMPSOUTH is $TEMPSOUTH"
#echo "TEMPNORTH IS $TEMPNORTH"
#echo ""
#exit 0

psbasemap -JX9.5iT/3.5i -R"$DEPTHWEST/$DEPTHEAST/$DEPTHSOUTH/$DEPTHNORTH" -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -K -V > temp_depth.ps

psxy depth_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> temp_depth.ps

psbasemap -JX9.5iT/3.5i -R"$TEMPWEST/$TEMPEAST/$TEMPSOUTH/$TEMPNORTH" -Bsx1O -Bpxa7df1d -BE -Byaf+l"$Y2_TITLE" -O -K -V >> temp_depth.ps

psxy temperature_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> temp_depth.ps

# Plot legend
pslegend -Dx7.9i/0.25i/1.4i/BL -J -F -O -V << EOF >> temp_depth.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Depth 
S 0.1i - 0.2i - 2p,blue 0.3i Temperature 
G 0.1i
EOF

# Output section; -Tg gives PNG output, -Te gives EPS output. 
psconvert -A -Tg temp_depth.ps -V -P
psconvert -A -Te temp_depth.ps -V -P

exit 0
