#! /bin/bash
#
# graph_sal_temp.sh: This script uses GMT to create a dual plot of salinity
# and temperature vs. time. The script formats the input files such that the first
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
#			 - Added notes on headskip and tailskip parameters (04-22-2016)
#
##############################################################################

INPUT=$1

X_TITLE="Date"
Y1_TITLE="Salinity (ppt)"
Y2_TITLE="Temperature (\260C)"
TITLE="Salinity vs. Temperature, June - August, 2015, Kittigazuit MID EWF-HI, NWT."

# The CTD files that are output from Ruskin usually have a large header at the
# beginning of the file. The headskip and tailskip parameters allow one to
# skip headers and bogus values at the beginning and end of the file,
# respectively. Tailskip determines what line to the end of the file you wish
# to omit from the output.
#
# NOTE: Since the temperature and salinity values usually come from the same
# ctd file, we can take advantage of this by only passing one pair of headskip
# and tailskip parameters.
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
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $4}' $INPUT > temperature.xy

# Concatenate the time and salinity columns from the input CTD file.
awk -v HEADSKIP=${HEADSKIP} -v TAILSKIP=${TAILSKIP} 'NR > HEADSKIP && NR < TAILSKIP {print $1"T"$2, $5}' $INPUT > salinity.xy

# Smooth the xy data using median filter
filter1d -f0T -FM1d temperature.xy --TIME_UNIT=d -V > temperature_filtered.xy 
filter1d -f0T -FM1d salinity.xy --TIME_UNIT=d -V > salinity_filtered.xy 

# Get the max/min extents of the salinity file.
SALINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T salinity_filtered.xy` 
echo $SALINFO

# Get the max/min extents of the temperature file.
TEMPINFO=`gmtinfo --FORMAT_DATE_IN=yyyy-mm-dd -f0T temperature_filtered.xy` 
echo $TEMPINFO

# Parse the min/max extents of the salinity file.
# The data will be output so that the format will be yyyy-mm-dd, the 
# datetime format expected by psbasemap.
SALWEST=`echo $SALINFO | awk '{print substr($5,2,19)}'`
SALEAST=`echo $SALINFO | awk '{print substr($5,22,19)}'`
SALSOUTH=`echo $SALINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f1`
SALNORTH=`echo $SALINFO | awk '{print $6}' | sed 's/<//g' | sed 's/>//g' | cut -d'/' -f2`

#echo "SALWEST is $SALWEST"
#echo "SALEAST IS $SALEAST"
#echo "SALSOUTH is $SALSOUTH"
#echo "SALNORTH IS $SALNORTH"
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

psbasemap -JX9.5iT/3.5i -R"$SALWEST/$SALEAST/$SALSOUTH/$SALNORTH" -Bsx1O -Bpxa7df1d+l"$X_TITLE" -Byaf+l"$Y1_TITLE" -BWSn+t"$TITLE" -K -V > saltemp.ps

psxy salinity_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,forestgreen -O -K -V >> saltemp.ps

psbasemap -JX9.5iT/3.5i -R"$TEMPWEST/$TEMPEAST/$TEMPSOUTH/$TEMPNORTH" -BE -Bsx1O -Bpxa7df1d -Byaf+l"$Y2_TITLE" -O -K -V >> saltemp.ps

psxy temperature_filtered.xy --FORMAT_DATE_IN=yyyy-mm-dd -f0T -J -R -Wthinner,blue -O -K -V >> saltemp.ps

# Plot legend
pslegend -Dx0.2i/0.2i/1.4i/BL -J -F -O -V << EOF >> saltemp.ps
G 0.05i
H 9 Helvetica-Bold Legend
G 0.1i
S 0.1i - 0.2i - 2p,forestgreen 0.3i Salinity 
S 0.1i - 0.2i - 2p,blue 0.3i Temperature 
G 0.1i
EOF

# Output section; -Tg gives PNG output, -Te gives EPS output. 
psconvert -A -Tg saltemp.ps -V -P
psconvert -A -Te saltemp.ps -V -P

exit 0
