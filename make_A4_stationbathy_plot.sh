#!/bin/bash
#  
#	make_A4_stationbathy_plot.sh
#
#	A script for generating GMT plots of station data with bathy
#   
#   Last modified: February 18, 2015
# 
# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

LABELS=""
TITLE="Amundsen Boxcore Stations, 2014"
REGION="-140/-114/68/74"
PROJ="-127/73/70/73"
SCALE="1:2000000"
#BATHY="Amundsen_Integrated_Bathy_Slope_2009_2011_25m.grd"
#OUTPUT=`basename $BATHY .grd`.ps
#COLORFILE=`basename $BATHY .grd`.cpt
#SHADEFILE=`basename $BATHY .grd`_shade.grd
OUTPUT=Amundsen_2014_Stations_with_Coastline.ps
#OUTPUT=Amundsen_Tracklines_2011-2014_with_Coastline.ps


#grdimage $BATHY -C$COLORFILE -Jl$PROJ/$SCALE -R$REGION -B2f2g2/1f1g1:."$TITLE": -I$SHADEFILE -nc -K -V > $OUTPUT 

#pscoast  -J -R -B -Df -Gtan -Lf-137.55/70.55/71/20+lKilometres+jr -W -O -K -Tx0.5i/1i/1 -V >> $OUTPUT 

# Use this pscoast line below if no bathy is being used in the script.
pscoast -Jl$PROJ/$SCALE -R$REGION -Bx5f5g5 -By2f2g2+t$TITLE -Df -Gtan -Lf-127/68.5/71/200+lKilometres+jr -W -K > $OUTPUT

#psscale -D0.15i/4.1i/1.75i/0.1i -B250:"":/:Metres: -O -K -C$COLORFILE -V >> $OUTPUT 

#psxy -J -R -O -K -Sc4p -Gblue -W -V $STATIONS >> $OUTPUT 
#
#pstext -J -R -O -K -D0.1 -V $LABELS >> $OUTPUT  
#
## This section below is optional; delete as needed.
# Insert generic contours here
#psxy -J -R -O -K -m -SqD3d:+l-50+s12 ../Contour_50m_LL.gmt >> $OUTPUT
#
#psxy -J -R -O -K -m -SqD2d:+l-100+s12 ../Contour_100m_clipped_LL.gmt >> $OUTPUT
#
#psxy -J -R -O -K -m -SqD2d:+l-1000+s12 ../Contour_1000m_clipped_LL.gmt >> $OUTPUT
#
#psxy -J -R -O -K -m -SqD2d:+l-2000+s12 ../Contour_2000m_clipped.gmt >> $OUTPUT


################################################################################
# Extra stations and their labels go in this section; modify as needed.

# 2014 Stations
psxy -J -R -O -K -Ss10p -Ggreen -W -V  2014804_Piston_Cores_from_ED.gmt >> $OUTPUT
#
pstext -J -R -O -Dj0.2 -V 2014804_Piston_Cores_Labels.gmt >> $OUTPUT

psxy -J -R -O -K -Sc7p -Gorange -W -V  Amundsen_2014804_Box_Cores_LL.gmt >> $OUTPUT

pstext -J -R -O -Dj0.2 -V Amundsen_2014804_Box_Cores_Labels.gmt >> $OUTPUT

## 2010 Stations
#psxy -J -R -O -K -Sc11p -Gorange -W -V 2010804_GSCA_Piston_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2010804_GSCA_Piston_Cores_Labels.xy >> $OUTPUT
#
#psxy -J -R -O -K -Ss11p -Gorange -W -V 2010804_GSCA_Box_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2010804_GSCA_Box_Cores_Labels.xy >> $OUTPUT
#
#psxy -J -R -O -K -St12p -Gorange -W -V 2010804_Industry_Piston_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2010804_Industry_Piston_Cores_Labels.xy >> $OUTPUT
#
#psxy -J -R -O -K -Sn11p -Gorange -W -V 2010804_Industry_Box_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2010804_Industry_Box_Cores_Labels.xy >> $OUTPUT
#
## 2009 Stations
#psxy -J -R -O -K -Sc12p -Gyellow -W -V 2009804_GSCA_Piston_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2009804_GSCA_Piston_Cores_Labels.xy >> $OUTPUT
#
#psxy -J -R -O -K -Ss11p -Gyellow -W -V 2009804_GSCA_Box_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2009804_GSCA_Box_Cores_Labels.xy >> $OUTPUT
#
#psxy -J -R -O -K -St12p -Gyellow -W -V 2009804_Industry_Piston_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2009804_Industry_Piston_Cores_Labels.xy >> $OUTPUT
#
#psxy -J -R -O -K -Sn8p -Gyellow -W -V 2009804_Industry_Box_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -Dj0.3 -V 2009804_Industry_Box_Cores_Labels.xy >> $OUTPUT

#
#pstext -J -R -O -K -D0.3 -V 2009_Cores_12_and_39_Labels.xy >> $OUTPUT

# 2008 Stations
#psxy -J -R -O -K -St12p -Gyellow -W -V 2008802_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -D-0.3 -V 2008802_Station_38_Label.xy >> $OUTPUT
#
#psxy -J -R -O -K -Sh12p -Gorange -W -V 2008801_Cores.xy >> $OUTPUT
#
#pstext -J -R -O -K -D0.3 -V 2008801_Cores_Labels.xy >> $OUTPUT
#
#pslegend legend.txt -J -R -B -O -Gwhite -Dx1i/16i/3i/1.75i/BL -F -V >> $OUTPUT

# Make a pdf from the postscript output
ps2raster ${OUTPUT} -Tj -V -P

exit 0
