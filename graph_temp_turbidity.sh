#! /bin/bash
#
# graph_temp_turbidity.sh: This script uses GMT to create a dual plot of
# temperature and turbidity vs. time. The script formats the input files such
# that the first column contains a GMT-style timestamp (eg,
# 23-Aug-2014T22:10:38.000), and the second contains the measured parameter
# (e.g., temperature or turbidity).
#
# Last modified: March 4, 2016
#
# CHANGELOG:	- Script created (03-04-2016)
#
##############################################################################

TEMPINPUT=$1
TURBINPUT=$2

X_TITLE="Date"
Y1_TITLE="Turbidity (NTU)"
Y2_TITLE="Temperature in \260 C"
TITLE="Turbidity vs. Temperature, East Channel, Tuktoyaktuk, NWT 2014-2015"


# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The skip paramter in this script represents the
# number of lines that must skipped to get past the header.
TEMP_HEADSKIP=$3
TEMP_TAILSKIP=$4
TURB_HEADSKIP=$5
TURB_TAILSKIP=$6

if [ -z $TEMP_HEADSKIP ] ; then
	TEMP_HEADSKIP=0
fi

if [ -z $TURB_HEADSKIP ] ; then
	TURB_HEADSKIP=0
fi

if [ $TEMP_TAILSKIP -eq 0 ] ; then
	# If no tailskip parameter is given, use the last line of the input file
	# as the default value (no data is skipped from the end of the file).
	TEMP_TAILSKIP=`wc -l $TEMPINPUT | awk '{print $1}'`
fi

if [ $TURB_TAILSKIP -eq 0 ] ; then
	TURB_TAILSKIP=`wc -l $TURBINPUT | awk '{print $1}'`
fi

# Concatenate the time and temperature columns from the input CTD file.
awk -v TEMP_HEADSKIP=${TEMP_HEADSKIP} -v TEMP_TAILSKIP=${TEMP_TAILSKIP} 'NR > TEMP_HEADSKIP && NR < TEMP_TAILSKIP {print $1"T"$2, $4}' $TEMPINPUT > temperature.xy

# Concatenate the time and turbidity columns from the input CTD file.
awk -v TURB_HEADSKIP=$TURB_HEADSKIP -v TURB_TAILSKIP=$TURB_TAILSKIP 'NR > TURB_HEADSKIP && NR < TURB_TAILSKIP {print $1"T"$2, $4}' $TURBINPUT > turbidity.xy


# Smooth the graphs using filter1d
filter1d -f0T -FM1d turbidity.xy --TIME_UNIT=d -V > turbidity_filtered.xy 
filter1d -f0T -FM1d temperature.xy --TIME_UNIT=d -V > temperature_filtered.xy 

# Get the max/min extents of the temperature file.
TEMPINFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd temperature_filtered.xy` 
echo $TEMPINFO

# Get the max/min extents of the turbidity file.
TURBINFO=`gmtinfo -f0T --FORMAT_DATE_IN=yyyy-mm-dd turbidity_filtered.xy` 
echo $TURBINFO

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

# Parse the min/max extents of the turbidity file.
# The data will be output so that the format will be yyyy-mm-dd, the 
# datetime format expected by psbasemap.
TURBWEST=`echo $TURBINFO | awk '{print substr($5,2,19)}'`
TURBEAST=`echo $TURBINFO | awk '{print substr($5,22,19)}'`
TURBSOUTH=`echo $TURBINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
TURBNORTH=`echo $TURBINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo ""
#echo "Turbidity file bounds:"
#echo $TURBWEST
#echo $TURBEAST
#echo $TURBSOUTH
#echo $TURBNORTH
#echo ""
#exit 0

psbasemap -JX9.5iT/3.5i -R"$TURBWEST/$TURBEAST/$TURBSOUTH/$TURBNORTH" -Bsx1Y -Bpx1O+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -K -V > tempturb.ps

# Plot turbidity
psxy turbidity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> tempturb.ps

psbasemap -J -R$TEMPWEST/$TEMPEAST/$TEMPSOUTH/$TEMPNORTH -Bsx1Y -Bpxa1Od -Byaf+l"$Y2_TITLE" -BE  -O -K -V >> tempturb.ps 

# Plot temperature
psxy temperature_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> tempturb.ps

# Plot legend
pslegend -Dx7.5i/2.5i/1.4i/BL -J -F -O << EOF >> tempturb.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Turbidity 
S 0.1i - 0.2i - 2p,blue 0.3i Temperature 
G 0.1i
EOF

# Plot output
psconvert -Tg tempturb.ps -V -P -A
psconvert -Te tempturb.ps -V -P -A

exit 0
