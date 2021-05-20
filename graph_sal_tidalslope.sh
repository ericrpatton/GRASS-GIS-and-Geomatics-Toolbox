#! /bin/bash
#
# graph_saltidalslope.sh: This script uses GMT to create a plot of salinity
# vs. tidal slope. 
#
# Last modified: March 4, 2016
#
# CHANGELOG: - Script created (03-04-2016)
#
##############################################################################

SALINPUT=$1
TIDALSLOPE_INPUT=$2

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of each file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
SAL_HEADSKIP=$3
SAL_TAILSKIP=$4
TIDALSLOPE_HEADSKIP=$5
TIDALSLOPE_TAILSKIP=$6

if [ -z $SAL_HEADSKIP ] ; then
	SAL_HEADSKIP=0
fi

if [ -z $TIDALSLOPE_HEADSKIP ] ; then
	TIDALSLOPE_HEADSKIP=0
fi

if [ $SAL_TAILSKIP -eq 0 ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	SAL_TAILSKIP=`wc -l $SALINPUT | awk '{print $1}'`
fi

if [ $TIDALSLOPE_TAILSKIP -eq 0 ] ; then
	TIDALSLOPE_TAILSKIP=`wc -l $TIDALSLOPE_INPUT | awk '{print $1}'`
fi

# Concatenate the time and Salinity columns from the input CTD file.
awk -v SAL_HEADSKIP=${SAL_HEADSKIP} -v SAL_TAILSKIP=${SAL_TAILSKIP} 'NR > SAL_HEADSKIP && NR < SAL_TAILSKIP {print $1"T"$2, $5}' $SALINPUT > salinity.xy

# Concatenate the time and tidalslope columns from the input CTD file.
awk -v TIDALSLOPE_HEADSKIP=$TIDALSLOPE_HEADSKIP -v TIDALSLOPE_TAILSKIP=$TIDALSLOPE_TAILSKIP 'NR > TIDALSLOPE_HEADSKIP && NR < TIDALSLOPE_TAILSKIP {print $1"T"$2, $6}' $TIDALSLOPE_INPUT > tidalslope.xy

# Smooth the graphs using filter1d
filter1d -f0T -FM1D salinity.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > salinity_filtered.xy
filter1d -f0T -FM1D tidalslope.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > tidalslope_filtered.xy

# Get the max/min extents of the salinity file. If using the unfiltered
# versions of the salinity and tidalslope, use --FORMAT_DATE_IN=dd-o-yyyy; if
# using the filtered versions, use --FORMAT_DATE_IN=yyyy-mm-dd
SALINFO=`gmtinfo --FORMAT_DATE_IN=dd-o-yyyy -f0T salinity.xy`
#SALINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T salinity_filtered.xy`
echo -e "\nRange of salinity file:"
echo $SALINFO
echo ""

# Get the max/min extents of the tidalslope file. If using the unfiltered
# versions of the salinity and tidalslope, use --FORMAT_DATE_IN=dd-o-yyyy; if
# using the filtered versions, use --FORMAT_DATE_IN=yyyy-mm-dd
TIDALSLOPE_INFO=`gmtinfo --FORMAT_DATE_IN=dd-o-yyyy -f0T tidalslope.xy`
#TIDALSLOPE_INFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T tidalslope_filtered.xy`
echo "Range of tidalslope file:"
echo $TIDALSLOPE_INFO
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

# Parse the min/max extents of the tidalslope file.
TIDALSLOPE_WEST=`echo $TIDALSLOPE_INFO | awk '{print substr($5,2,19)}'`
TIDALSLOPE_EAST=`echo $TIDALSLOPE_INFO | awk '{print substr($5,22,19)}'`
TIDALSLOPE_SOUTH=`echo $TIDALSLOPE_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
TIDALSLOPE_NORTH=`echo $TIDALSLOPE_INFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo "Tidalslope file bounds:"
echo $TIDALSLOPE_WEST
echo $TIDALSLOPE_EAST
echo $TIDALSLOPE_SOUTH
echo $TIDALSLOPE_NORTH
echo ""
#exit 0 

# psbasemap call for looking at tidalslope changes over one tidal regime;
# comment out as necessary.
psbasemap -JX9.5iT/3.5i -R"$SALWEST/$SALEAST/$SALSOUTH/$SALNORTH" -Bpxa4hf1h -Bsxa1D+l"2014" -Byaf+l"Salinity (ppt)" -BWSn+t"Salinity vs. Tidal Slope, East Channel, Tuktoyaktuk, NWT " -V -K --FORMAT_CLOCK_MAP="hh:mm" --FORMAT_DATE_MAP="o dd" > sal_tidalslope_one_cycle.ps

# MULTI-MONTH OR YEAR
#psbasemap -JX9.5iT/3.5i -R"$SALWEST/$SALEAST/$SALSOUTH/$SALNORTH" -Bsx1Y -Bpxa1Od+l"Date" -Byaf+l"Salinity (ppt)" -BWSn+t"Salinity vs. Tidal Slope, East Channel, Tuktoyaktuk, NWT 2014-2015" -V -K > sal_tidalslope.ps

# Plot salinity
#psxy salinity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> sal_tidalslope.ps
psxy salinity.xy --FORMAT_DATE_IN=dd-o-yyyy -f0T -J -R -Wthinner,forestgreen -O -K -V >> sal_tidalslope_one_cycle.ps

# psbasemap call for looking at tidalslope changes over one tidal regime;
# comment out as necessary.
psbasemap -J -R$TIDALSLOPE_WEST/$TIDALSLOPE_EAST/$TIDALSLOPE_SOUTH/$TIDALSLOPE_NORTH -Bsxa1D -Bpxa3hf1h -Byaf+l"Tidal Slope in XX" -BE  -O -K -V >> sal_tidalslope_one_cycle.ps

# MULTI-MONTH OR YEAR
#psbasemap -J -R$TIDALSLOPE_WEST/$TIDALSLOPE_EAST/$TIDALSLOPE_SOUTH/$TIDALSLOPE_NORTH -Bsx1Y -Bpxa1Od -Byaf+l"Tidal Slope in XX" -BE  -O -K -V >> sal_tidalslope.ps

# Plot tidalslope
#psxy tidalslope_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> sal_tidalslope.ps
psxy tidalslope.xy --FORMAT_DATE_IN=dd-o-yyyy -f0T -J -R -Wthinner,blue -O -K -V >> sal_tidalslope_one_cycle.ps

# Plot legend
pslegend -Dx7.6i/2.6i/1.4i/BL -J -F -O << EOF >> sal_tidalslope_one_cycle.ps
#pslegend -Dx7.6i/2.6i/1.4i/BL -J -F -O << EOF >> sal_tidalslope.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Salinity
S 0.1i - 0.2i - 2p,blue 0.3i Tidal Slope
G 0.1i
EOF

# Plot output
#psconvert -Tg sal_tidalslope.ps -V -P -A
#psconvert -Te sal_tidalslope.ps -V -P -A
psconvert -Tg sal_tidalslope_one_cycle.ps -V -P -A
psconvert -Te sal_tidalslope_one_cycle.ps -V -P -A

exit 0
