#!/bin/bash
#  
#	make_stationbathy_plot.sh
#
#	A script for generating GMT plots of station data with bathy
#   
#   Last modified: June 19, 2012
# 
##############################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT bathyfile station_file label_file \n"
	exit 1
fi

BATHY=$1
STATIONS=$2
LABELS=$3

if [ -z "$BATHY" ] ; then
	read -p "Enter the bathy GMT grid file: " BATHY
fi

if [ -z "$STATIONS" ] ; then
	read -p "Enter the stations xy file: " STATIONS
fi	

if [ -z "$LABELS" ] ; then
	read -p "Enter the labels xy file : " LABELS
fi	

REGION=`mb.getregion` 
PROJ=-135.333/70
SCALE=1:475000
OUTPUT=`basename $BATHY .grd`.ps
COLORFILE=`basename $BATHY .grd`.cpt
SHADEFILE=`basename $BATHY .grd`_shade.grd

grdimage $BATHY -C$COLORFILE -Jm$PROJ/$SCALE -R$REGION -B30mf30mg30m/15mf15mg15m:."Amundsen 2008-2010 Piston Core Locations with Radiocarbon Dates": -I$SHADEFILE -Sb/0.2 -K -V > $OUTPUT 

pscoast  -J -R -B -Df -Gtan -Lf-137.55/70.55/71/20+lKilometres+jr -W -O -K -Tx0.6i/0.7i/1.25 -V >> $OUTPUT 

psscale -D0.25i/7.5i/1.75i/0.1i -B250:"":/:Metres: -O -K -C$COLORFILE -V >> $OUTPUT 

psxy -J -R -O -K -Sc6p -Gblue -W -V $STATIONS >> $OUTPUT 

pstext -J -R -O -K -D0.1 -V $LABELS >> $OUTPUT  

# This section below is optional; delete as needed.
psxy -J -R -O -K -Ss7p -Ggreen -W -V 2009_Cores.xy >> $OUTPUT

pstext -J -R -O -K -D-0.1 -V 2009_Cores_Labels.xy >> $OUTPUT

pstext -J -R -O -K -D0.1 -V 2009_Cores_12_and_39_Labels.xy >> $OUTPUT

psxy -J -R -O -K -St7p -Gpurple -W -V 2008802_Cores.xy >> $OUTPUT

pstext -J -R -O -K -D-0.1 -V 2008802_Station_38_Label.xy >> $OUTPUT

psxy -J -R -O -K -Sh7p -Gorange -W -V 2008801_Cores.xy >> $OUTPUT

pstext -J -R -O -K -D0.1 -V 2008801_Cores_Labels.xy >> $OUTPUT

pslegend legend.txt -J -R -B -O -Gwhite -Dx1i/16i/3i/1.75i/BL -F >> $OUTPUT

# Make a pdf from the postscript output
ps2raster ${OUTPUT} -Tf -V

exit 0
