#! /bin/bash
#
# graph_saldepth.sh: This script uses GMT to create a dual plot of salinity
# and depth vs. time. The script formats the input files such that the first
# column contains a GMT-style timestamp (eg, 23-Aug-2014T22:10:38.000), and
# the second contains the measured parameter (e.g., depth or sailinty).
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

SALINPUT=$1
DEPTHINPUT=$2

X_TITLE="Date"
Y1_TITLE="Salinity (ppt)"
Y2_TITLE="Depth (m)"
TITLE="Salinity vs. Depth, June - August 2015, Kittigazuit MID EWF-HI, NWT."

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of the file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
SAL_HEADSKIP=$3
SAL_TAILSKIP=$4
DEPTH_HEADSKIP=$5
DEPTH_TAILSKIP=$6

if [ $SAL_TAILSKIP -eq 0 ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	SAL_TAILSKIP=`wc -l $SALINPUT | awk '{print $1}'`
fi

if [ $DEPTH_TAILSKIP -eq 0 ] ; then
	DEPTH_TAILSKIP=`wc -l $DEPTHINPUT | awk '{print $1}'`
fi

# Concatenate the time and Salinity columns from the input CTD file.
awk -v SAL_HEADSKIP=${SAL_HEADSKIP} -v SAL_TAILSKIP=${SAL_TAILSKIP} 'NR > SAL_HEADSKIP && NR < SAL_TAILSKIP {print $1"T"$2, $8}' $SALINPUT > salinity.xy

# Concatenate the time and depth columns from the input CTD file.
awk -v DEPTH_HEADSKIP=$DEPTH_HEADSKIP -v DEPTH_TAILSKIP=$DEPTH_TAILSKIP 'NR > DEPTH_HEADSKIP && NR < DEPTH_TAILSKIP {print $1"T"$2, $7}' $DEPTHINPUT > depth.xy

# Smooth the graphs using filter1d
filter1d -f0T -FM1d salinity.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > salinity_filtered.xy
filter1d -f0T -FM1d depth.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > depth_filtered.xy

# Get the max/min extents of the salinity file.
SALINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T salinity_filtered.xy`
#SALINFO=`gmtinfo -f0T salinity.xy`
echo -e "\nRange of salinity file:"
echo $SALINFO
echo ""

# Get the max/min extents of the depth file.
DEPTHINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T depth_filtered.xy`
echo "Range of depth file:"
echo $DEPTHINFO
echo ""

# Parse the min/max extents of the salinity file.
# The data will be output so that the format will be yyyy-mm-dd, the
# datetime format expected by psbasemap.
SALWEST=`echo $SALINFO | awk '{print substr($5,2,19)}'`
SALEAST=`echo $SALINFO | awk '{print substr($5,22,19)}'`
SALSOUTH=`echo $SALINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
SALNORTH=`echo $SALINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo ""
echo "Salinity file bounds:"
echo $SALWEST
echo $SALEAST
echo $SALSOUTH
echo $SALNORTH
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

psbasemap -JX9.5iT/3.5i -R"$SALWEST/$SALEAST/$SALSOUTH/$SALNORTH" -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -K -V > saldepth.ps

psxy salinity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> saldepth.ps

psbasemap -JX9.5iT/3.5i -R"$DEPTHWEST/$DEPTHEAST/$DEPTHSOUTH/$DEPTHNORTH" -BE -Byaf+l"$Y2_TITLE" -O -K -V >> saldepth.ps

psxy depth_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> saldepth.ps

# Plot legend
pslegend -Dx0.5i/0.3i/1.2i/BL -J -F -O -V << EOF >> saldepth.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Salinity 
S 0.1i - 0.2i - 2p,blue 0.3i Depth 
G 0.1i
EOF

# Output section; -Tg gives PNG output, -Te gives EPS output. 
psconvert -A -Tg saldepth.ps -V -P
psconvert -A -Te saldepth.ps -V -P

exit 0
