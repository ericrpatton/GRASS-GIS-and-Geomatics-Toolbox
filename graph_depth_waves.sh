# /bin/bash
#
# graph_depth_waves.sh: This script uses GMT to create a plot of
# significant wave height vs. depth. It expects a GMT-style timestamp (eg,
# 23-Aug-2014T22:10:38.000) as the first column, and the significant wave
# height value as the second.
#
# Last modified: April 21, 2016
#
# CHANGELOG: - Script created (04-21-2016)
#
##############################################################################

INPUT=$1

X_TITLE="Date"
Y1_TITLE="Significant Wave Height in XX"
Y2_TITLE="Depth in m"
TITLE="Significant Wave Height vs. Depth, June - August 2015, Kittigazuit MID EWF-HI, NWT."

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of the file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
# Since the significant wave height and depth values typically come from the
# same file, we can take advantage of that and use the same headskip and
# tailskip values
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

# Concatenate the time and wave height columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $8}' $INPUT > sigwaves.xy

# Concatenate the time and depth columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $6}' $INPUT > depths.xy

# Smooth the significant wave xy data using median filter
filter1d -f0T -FM1d sigwaves.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > sigwaves_filtered.xy 

# Smooth the depth xy data using median filter
filter1d -f0T -FM1d depths.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > depths_filtered.xy 

# Get the max/min extents of the significant wave file.
SIGWAVE_INFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd --TIME_UNIT=d sigwaves_filtered.xy` 

# Get the max/min extents of the depth file.
DEPTHS_INFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd --TIME_UNIT=d depths_filtered.xy` 

# Parse the min/max extents of the sigificant wave file.
SIGWAVE_WEST=`echo $SIGWAVE_INFO | awk '{print substr($5,2,19)}'`
SIGWAVE_EAST=`echo $SIGWAVE_INFO | awk '{print substr($5,22,19)}'`
SIGWAVE_SOUTH=`echo $SIGWAVE_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
SIGWAVE_NORTH=`echo $SIGWAVE_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo "sigwavewest is $SIGWAVE_WEST."
#echo "sigwaveeast is $SIGWAVE_EAST."
#echo "sigwavesouth is $SIGWAVE_SOUTH."
#echo "sigwavenorth is $SIGWAVE_NORTH."
#echo ""
#exit 0

# Parse the min/max extents of the depths file.
DEPTHS_WEST=`echo $DEPTHS_INFO | awk '{print substr($5,2,19)}'`
DEPTHS_EAST=`echo $DEPTHS_INFO | awk '{print substr($5,22,19)}'`
DEPTHS_SOUTH=`echo $DEPTHS_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
DEPTHS_NORTH=`echo $DEPTHS_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo "Depthwest is $DEPTHS_WEST."
#echo "Deptheast is $DEPTHS_EAST."
#echo "Depthsouth is $DEPTHS_SOUTH."
#echo "Depthnorth is $DEPTHS_NORTH."
#echo ""
#exit 0

psbasemap -JX9iT/3i -R$SIGWAVE_WEST/$SIGWAVE_EAST/$SIGWAVE_SOUTH/$SIGWAVE_NORTH -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -V -K > depth_waves.ps 

psxy sigwaves_filtered.xy  -J -R -f0T --FORMAT_DATE_IN=yyyy-mm-dd -Wthin,red -O -K -V >> depth_waves.ps

psbasemap -J -R$DEPTHS_WEST/$DEPTHS_EAST/$DEPTHS_SOUTH/$DEPTHS_NORTH -BE -Byaf+l"$Y2_TITLE" -O -K -V >> depth_waves.ps

psxy depths_filtered.xy  -J -R -f0T --FORMAT_DATE_IN=yyyy-mm-dd -Wthin,blue -O -K -V >> depth_waves.ps

# Plot legend
pslegend -Dx0.1i/2.3i/1.5i/1.7/BL -J -F -O -V << EOF >> depth_waves.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,red 0.3i Significant Waves
S 0.1i - 0.2i - 2p,blue 0.3i Depth
G 0.1i
EOF

# Output section
psconvert -Tg depth_waves.ps -V -P -A
psconvert -Te depth_waves.ps -V -P -A

exit 0
