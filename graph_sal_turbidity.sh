#! /bin/bash
#
# graph_salturbidity.sh: This script uses GMT to create a dual plot of
# turbidity and salinity vs. time. The script formats the input files such that
# the first column contains a GMT-style timestamp (eg,
# 23-Aug-2014T22:10:38.000), and the second contains the measured parameter
# (e.g., salinity or turbidity).
# Last modified: March 4, 2016
#
# CHANGELOG: - Script created (03-04-2016)
#
##############################################################################

SALINPUT=$1
TURBINPUT=$2

X_TITLE="Date"
Y1_TITLE="Salinity (ppt)"
Y2_TITLE="Turbidity in NTU"
TITLE="Salinity vs. Turbidity, 2014-2015, East Channel, Tuktoyaktuk, NWT."
# The CTD files that are output from Ruskin usually have a large header at the

# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of each file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
# TO-DO: Try to come up with a sane way of parsing the Ruskin file
# automatically.
SAL_HEADSKIP=$3
SAL_TAILSKIP=$4
TURB_HEADSKIP=$5
TURB_TAILSKIP=$6

if [ -z $SAL_HEADSKIP ] ; then
	SAL_HEADSKIP=0
fi

if [ -z $TURB_HEADSKIP ] ; then
	TURB_HEADSKIP=0
fi

if [ $SAL_TAILSKIP -eq 0 ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	SAL_TAILSKIP=`wc -l $SALINPUT | awk '{print $1}'`
fi

if [ $TURB_TAILSKIP -eq 0 ] ; then
	TURB_TAILSKIP=`wc -l $TURBINPUT | awk '{print $1}'`
fi

# Concatenate the time and Salinity columns from the input CTD file.
awk -v SAL_HEADSKIP=${SAL_HEADSKIP} -v SAL_TAILSKIP=${SAL_TAILSKIP} 'NR > SAL_HEADSKIP && NR < SAL_TAILSKIP {print $1"T"$2, $5}' $SALINPUT > salinity.xy

# Concatenate the time and turbidity columns from the input CTD file.
awk -v TURB_HEADSKIP=$TURB_HEADSKIP -v TURB_TAILSKIP=$TURB_TAILSKIP 'NR > TURB_HEADSKIP && NR < TURB_TAILSKIP {print $1"T"$2, $3}' $TURBINPUT > turbidity.xy

# Smooth the graphs using filter1d
filter1d -f0T -FM1d salinity.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > salinity_filtered.xy
filter1d -f0T -FM1d turbidity.xy --TIME_UNIT=d -V | awk '{print $1, $2}' > turbidity_filtered.xy

# Get the max/min extents of the salinity file.
SALINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T salinity_filtered.xy`
echo -e "\nRange of salinity file:"
echo $SALINFO
echo ""

# Get the max/min extents of the turbidity file.
TURBINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T turbidity_filtered.xy`
echo "Range of turbidity file:"
echo $TURBINFO
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

# Parse the min/max extents of the turbidity file.
TURBWEST=`echo $TURBINFO | awk '{print substr($5,2,19)}'`
TURBEAST=`echo $TURBINFO | awk '{print substr($5,22,19)}'`
TURBSOUTH=`echo $TURBINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
TURBNORTH=`echo $TURBINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

echo "Turbidity file bounds:"
echo $TURBWEST
echo $TURBEAST
echo $TURBSOUTH
echo $TURBNORTH
echo ""
#exit 0

psbasemap -JX9.5iT/3.5i -R"$SALWEST/$SALEAST/$SALSOUTH/$SALNORTH" -Bsx1Y -Bpx1O+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -K -V > salturb.ps

# Plot salinity
psxy salinity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> salturb.ps

psbasemap -J -R$TURBWEST/$TURBEAST/$TURBSOUTH/$TURBNORTH -Bsx2Y -Bpxa1Od -Byaf+l"$Y2_TITLE" -BE  -O -K -V >> salturb.ps

# Plot turbidity
psxy turbidity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> salturb.ps

# Plot legend
pslegend -Dx7.5i/2.5i/1.4i/BL -J -F -O << EOF >> salturb.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Salinity
S 0.1i - 0.2i - 2p,blue 0.3i Turbidity
G 0.1i
EOF

# Plot output
psconvert -Tg salturb.ps -V -P -A
psconvert -Te salturb.ps -V -P -A

exit 0
