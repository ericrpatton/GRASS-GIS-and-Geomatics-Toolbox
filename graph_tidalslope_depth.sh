#! /bin/bash
#
# graph_tidalslope_depth.sh: This script uses GMT to create a dual plot of
# tidal slope and depth vs. time. The script formats the input files such that
# the first column contains a GMT-style timestamp (eg,
# 23-Aug-2014T22:10:38.000), and the second contains the measured parameter
# (e.g., depth or tidal slope).
#
# Last modified: March 4, 2016
#
# CHANGELOG:	- Script created (03-04-2016)
#
##############################################################################

TIDALSLOPE_INPUT=$1 
DEPTHINPUT=$2

X_TITLE="Date"
Y1_TITLE="Tidal Slope in XX"
Y2_TITLE="Depth (m)"
TITLE="Tidal Slope vs. Depth, June - August 2015, Kittigazuit MID EWF-HI, NWT."

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of the file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
TIDALSLOPE_HEADSKIP=$3
TIDALSLOPE_TAILSKIP=$4
DEPTH_HEADSKIP=$5
DEPTH_TAILSKIP=$6

if [ $TIDALSLOPE_TAILSKIP -eq 0 ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	TIDALSLOPE_TAILSKIP=`wc -l $TIDALSLOPE_INPUT | awk '{print $1}'`
fi

if [ $DEPTH_TAILSKIP -eq 0 ] ; then
	DEPTH_TAILSKIP=`wc -l $DEPTHINPUT | awk '{print $1}'`
fi

# Concatenate the time and Tidal Slope columns from the input CTD file.
awk -v TIDALSLOPE_HEADSKIP=${TIDALSLOPE_HEADSKIP} -v TIDALSLOPE_TAILSKIP=${TIDALSLOPE_TAILSKIP} 'NR > TIDALSLOPE_HEADSKIP && NR < TIDALSLOPE_TAILSKIP {print $1"T"$2, $7}' $TIDALSLOPE_INPUT > tidalslope.xy

# Concatenate the time and depth columns from the input CTD file.
awk -v DEPTH_HEADSKIP=$DEPTH_HEADSKIP -v DEPTH_TAILSKIP=$DEPTH_TAILSKIP 'NR > DEPTH_HEADSKIP && NR < DEPTH_TAILSKIP {print $1"T"$2, $6}' $DEPTHINPUT > depth.xy

# Smooth the graphs using filter1d
filter1d -f0T -FM1d tidalslope.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > tidalslope_filtered.xy
filter1d -f0T -FM1d depth.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > depth_filtered.xy

# Get the max/min extents of the tidalslope file.
#TIDALSLOPE_INFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T tidalslope_filtered.xy`
TIDALSLOPE_INFO=`gmtinfo -f0T tidalslope.xy`
echo -e "\nRange of tidalslope file:"
echo $TIDALSLOPE_INFO
echo ""

# Get the max/min extents of the depth file.
DEPTHINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T depth_filtered.xy`
echo "Range of depth file:"
echo $DEPTHINFO
echo ""

# Parse the min/max extents of the tidalslope file.
# The data will be output so that the format will be yyyy-mm-dd, the
# datetime format expected by psbasemap.
TIDALSLOPE_WEST=`echo $TIDALSLOPE_INFO | awk '{print substr($5,2,19)}'`
TIDALSLOPE_EAST=`echo $TIDALSLOPE_INFO | awk '{print substr($5,22,19)}'`
TIDALSLOPE_SOUTH=`echo $TIDALSLOPE_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
TIDALSLOPE_NORTH=`echo $TIDALSLOPE_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo ""
echo "Tidal Slope file bounds:"
echo $TIDALSLOPE_WEST
echo $TIDALSLOPE_EAST
echo $TIDALSLOPE_SOUTH
echo $TIDALSLOPE_NORTH
echo ""
#exit 0

# Parse the min/max extents of the depth file.
DEPTHWEST=`echo $DEPTHINFO | awk '{print substr($5,2,19)}'`
DEPTHEAST=`echo $DEPTHINFO | awk '{print substr($5,22,19)}'`
DEPTHSOUTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
DEPTHNORTH=`echo $DEPTHINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo "Depth file bounds:"
echo $DEPTHWEST
echo $DEPTHEAST
echo $DEPTHSOUTH
echo $DEPTHNORTH
echo ""
#exit 0

psbasemap -JX9.5iT/3.5i -R"$TIDALSLOPE_WEST/$TIDALSLOPE_EAST/$TIDALSLOPE_SOUTH/$TIDALSLOPE_NORTH" -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -K -V > tidalslope_depth.ps

psxy tidalslope_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> tidalslope_depth.ps
#psxy tidalslope.xy -f0T -J -R -Wthinner,red -O -K -V >> tidalslope_depth.ps

psbasemap -JX9.5iT/3.5i -R"$DEPTHWEST/$DEPTHEAST/$DEPTHSOUTH/$DEPTHNORTH" -BE -Byaf+l"$Y2_TITLE" -O -K -V >> tidalslope_depth.ps

psxy depth_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> tidalslope_depth.ps

# Plot legend
pslegend -Dx1.0i/0.15i/1.4i/BL -J -F -O -V << EOF >> tidalslope_depth.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Tidal Slope 
S 0.1i - 0.2i - 2p,blue 0.3i Depth 
G 0.1i
EOF

# Output section; -Tg gives PNG output, -Te gives EPS output. 
psconvert -A -Tg tidalslope_depth.ps -V -P
psconvert -A -Te tidalslope_depth.ps -V -P

exit 0
