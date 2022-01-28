#!/bin/bash
#  
#	make_B0_stationbathy_plot.sh
#
#	A script for generating GMT plots of station data with bathy
#   
#   Last modified: November 19, 2012

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT bathyfile station_file label_file \n"
	exit 1
fi


#if  [ -z "$GISBASE" ] ; then
#    echo "You must be in GRASS GIS to run this program."
#    exit 1
#fi

BATHY=Amundsen_Integrated_Bathy_Slope_2009_2011_25m.grd
# STATIONS=2010_Cores.xy
# LABELS=2010_Cores_Labels.xy

#if [ -z "$BATHY" ] ; then
#	read -p "Enter the bathy GMT grid file: " BATHY
#fi
#
#if [ -z "$STATIONS" ] ; then
#	read -p "Enter the stations xy file: " STATIONS
#fi	
#
#if [ -z "$LABELS" ] ; then
#	read -p "Enter the labels xy file : " LABELS
#fi	

REGION=-137.1667/-135.5/70.416666/71
PROJ=-135.333/70
SCALE=1:74000
OUTPUT=Amundsen_2009_2014_Cores.ps
#COLORFILE=`basename $BATHY .grd`.cpt
#SHADEFILE=`basename $BATHY .grd`_shade.grd
COLORFILE=Amundsen_Integrated_Bathy_Slope_2009_2011_25m.cpt
SHADEFILE=Amundsen_Integrated_Bathy_Slope_2009_2011_25m_shade.grd

grdimage $BATHY -C$COLORFILE -Jm$PROJ/$SCALE -R$REGION -B30mf30mg30m/15mf15mg15m:."Amundsen 2009-2014 Industry and GSC-A Piston/Box Core Locations": -I$SHADEFILE -nb -K -V -X1.5i -Y1.5i > $OUTPUT 

pscoast  -J -R -B -Df -Gtan -Lf-137.55/70.45/71/20+lKilometres+jr -W -O -K -Tx2.2i/8i/6 -V -U >> $OUTPUT 

psscale -D4i/10i/6i/0.5i -B250:"":/:Metres: -O -K -C$COLORFILE -V >> $OUTPUT 

#psxy -J -R -O -K -Sc11p -Gorange -W -V $STATIONS >> $OUTPUT 
#
#pstext -J -R -O -K -D0.3 -V $LABELS >> $OUTPUT  

# Insert generic contours here
#psxy -J -R -O -K -m -SqD3d:+l-50+s12 ../Contour_50m_LL.gmt >> $OUTPUT
#
#psxy -J -R -O -K -m -SqD2d:+l-100+s12 ../Contour_100m_clipped_LL.gmt >> $OUTPUT
#
#psxy -J -R -O -K -m -SqD2d:+l-1000+s12 ../Contour_1000m_clipped_LL.gmt >> $OUTPUT
#
#psxy -J -R -O -K -m -SqD2d:+l-2000+s12 ../Contour_2000m_clipped.gmt >> $OUTPUT

# Extra stations and their labels go in this section; modify as needed.

# 2010 Stations
psxy -J -R -O -K -Sc11p -Gorange -W -V 2010804_GSCA_Piston_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2010804_GSCA_Piston_Cores_Labels.xy >> $OUTPUT

psxy -J -R -O -K -Ss11p -Gorange -W -V 2010804_GSCA_Box_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2010804_GSCA_Box_Cores_Labels.xy >> $OUTPUT

psxy -J -R -O -K -St12p -Gorange -W -V 2010804_Industry_Piston_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2010804_Industry_Piston_Cores_Labels.xy >> $OUTPUT

psxy -J -R -O -K -Sn11p -Gorange -W -V 2010804_Industry_Box_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2010804_Industry_Box_Cores_Labels.xy >> $OUTPUT

# 2009 Stations
psxy -J -R -O -K -Sc12p -Gyellow -W -V 2009804_GSCA_Piston_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2009804_GSCA_Piston_Cores_Labels.xy >> $OUTPUT

psxy -J -R -O -K -Ss11p -Gyellow -W -V 2009804_GSCA_Box_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2009804_GSCA_Box_Cores_Labels.xy >> $OUTPUT

psxy -J -R -O -K -St12p -Gyellow -W -V 2009804_Industry_Piston_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2009804_Industry_Piston_Cores_Labels.xy >> $OUTPUT

psxy -J -R -O -K -Sn8p -Gyellow -W -V 2009804_Industry_Box_Cores.xy >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2009804_Industry_Box_Cores_Labels.xy >> $OUTPUT

# 2014 Stations
psxy -J -R -O -K -St12p -Ggreen -W -V  2014804_Piston_Cores_from_ED.gmt >> $OUTPUT

pstext -J -R -O -K -Dj0.3 -V 2014804_Piston_Cores_Labels.gmt >> $OUTPUT

#
#pstext -J -R -O -K -D0.3 -V 2009_Cores_12_and_39_Labels.xy >> $OUTPUT
#
#psxy -J -R -O -K -St12p -Gyellow -W -V 2008802_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -D-0.3 -V 2008802_Station_38_Label.xy >> $OUTPUT
#
#psxy -J -R -O -K -Sh12p -Gorange -W -V 2008801_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -D0.3 -V 2008801_Cores_Labels.xy >> $OUTPUT

pslegend legend.txt -J -R -B -O -Dx0.4i/14i/3.7i/3.2i/BL -F+gwhite+i >> $OUTPUT

# Make a pdf from the postscript output
ps2raster ${OUTPUT} -Tf -V 

exit 0
