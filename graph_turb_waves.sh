#! /bin/bash
#
# graph_turb_waves.sh: This script uses GMT to create a dual plot of turbidity
# (either sensor can be chosen) and significant wave height vs. time. The
# script formats the input files such that the first column contains a
# GMT-style timestamp (eg, 23-Aug-2014T22:10:38.000), and the second contains
# the measured parameter (e.g., wave height or turbidity).
#
# Last modified: April 25, 2016
#
# CHANGELOG: - Script created (04-20-2016)
#			 - Added note that we are using significant waves (04-25-2016)
#
##############################################################################

TURB_INPUT=$1
WAVE_INPUT=$2

X_TITLE="Date"
Y1_TITLE="Significant wave height"
Y2_TITLE="Turbidity in NTU"
TITLE="Siginificant Wave Height vs. Turbidity, June - August 2015, Kittigazuit MID EWF-HI, NWT."

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of each file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
TURB_HEADSKIP=$3
TURB_TAILSKIP=$4
WAVE_HEADSKIP=$5
WAVE_TAILSKIP=$6

if [ $TURB_TAILSKIP -eq 0 ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	TURB_TAILSKIP=`wc -l $TURB_INPUT | awk '{print $1}'`
fi

if [ $WAVE_TAILSKIP -eq 0 ] ; then
	WAVE_TAILSKIP=`wc -l $WAVE_INPUT | awk '{print $1}'`
fi

# Concatenate the time and Significant Wave columns from the input CTD file.
# NOTE: We are using siginificant waves here (7th column of input data)
awk -v WAVE_HEADSKIP=${WAVE_HEADSKIP} -v WAVE_TAILSKIP=${WAVE_TAILSKIP} 'NR > WAVE_HEADSKIP && NR < WAVE_TAILSKIP {print $1"T"$2, $8}' $WAVE_INPUT > waves.xy

# Concatenate the time and turbidity columns from the input CTD file.
awk -v TURB_HEADSKIP=$TURB_HEADSKIP -v TURB_TAILSKIP=$TURB_TAILSKIP 'NR > TURB_HEADSKIP && NR < TURB_TAILSKIP {print $1"T"$2, $3}' $TURB_INPUT > turbidity.xy

#head -n20 turbidity.xy
#echo ""
#exit 0

# Smooth the graphs using filter1d
filter1d -f0T -FM1d waves.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > waves_filtered.xy
filter1d -f0T -FM1d turbidity.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > turbidity_filtered.xy

# Get the max/min extents of the Wave file.
WAVEINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T waves_filtered.xy`
echo -e "\nRange of wave file:"
echo $WAVEINFO
echo ""

# Get the max/min extents of the turbidity file.
TURBINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T turbidity_filtered.xy`
echo "Range of turbidity file:"
echo $TURBINFO
echo ""

# Parse the min/max extents of the Waves file.
# The data will be output so that the format will be yyyy-mm-dd, the
# datetime format expected by psbasemap.
WAVE_WEST=`echo $WAVEINFO | awk '{print substr($5,2,19)}'`
WAVE_EAST=`echo $WAVEINFO | awk '{print substr($5,22,19)}'`
WAVE_SOUTH=`echo $WAVEINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
WAVE_NORTH=`echo $WAVEINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo ""
echo "Significant Waves file bounds:"
echo $WAVE_WEST
echo $WAVE_EAST
echo $WAVE_SOUTH
echo $WAVE_NORTH
echo ""
#exit 0

# Parse the min/max extents of the turbidity file.
TURB_WEST=`echo $TURBINFO | awk '{print substr($5,2,19)}'`
TURB_EAST=`echo $TURBINFO | awk '{print substr($5,22,19)}'`
TURB_SOUTH=`echo $TURBINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
TURB_NORTH=`echo $TURBINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo "Turbidity file bounds:"
echo $TURB_WEST
echo $TURB_EAST
echo $TURB_SOUTH
echo $TURB_NORTH
echo ""
#exit 0

psbasemap -JX9.5iT/3.5i -R"$WAVE_WEST/$WAVE_EAST/$WAVE_SOUTH/$WAVE_NORTH" -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -K -V > turbwaves.ps

# Plot Waves
psxy waves_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> turbwaves.ps

psbasemap -J -R$TURB_WEST/$TURB_EAST/$TURB_SOUTH/$TURB_NORTH -Bsx2Y -Bpxa1Od -Byaf+l"$Y2_TITLE" -BE  -O -K -V >> turbwaves.ps

# Plot turbidity
psxy turbidity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> turbwaves.ps

# Plot legend
pslegend -Dx8.0i/2.6i/1.5i/BL -J -F -O << EOF >> turbwaves.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Significant Waves
S 0.1i - 0.2i - 2p,blue 0.3i Turbidity
G 0.1i
EOF

# Plot output
psconvert -Tg turbwaves.ps -V -P -A
psconvert -Te turbwaves.ps -V -P -A

exit 0
