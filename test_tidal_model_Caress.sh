##############################################################
#
# Example processing of Kongsberg multibeam data testing
# tide correction
#
# Grid and mosaic bounds are hard wired to allow differencing
#
# David W. Caress
# 7 January 2016
#
##############################################################
#
# Preliminary processing:
# Preprocess the multibeam data, run mbprocess,
# and estimate attitude time lag
#
# Generate a time ordered datalist of the *.all files
chmod -x *.all
chmod +r *.all
/bin/ls -1 *all | sed "s/_20/ 20/" | awk '{print $2" "$1}' | sort | awk '{print $2"_"$1" 58"}' > datalist_log.mb-1
mbdatalist -I datalist_log.mb-1 -O -V
mbkongsbergpreprocess -I datalist_log.mb-1 -V

# Get datalist of raw *.mb59 files plus ancilliary files
/bin/ls -1 *.mb59 | grep -v "p.mb59" | awk '{print $1" 59"}' > datalist.mb-1
mbdatalist -V -O -Z

# Uncomment to extract original svp and turn on bathymetry recalculation
#mbsvplist -P -V

# Edit bathymetry
# mbedit
mbeditviz -I datalist.mb-1

# Get tide models and set for use by mbprocess
mbotps -I datalist.mb-1 -M -D60.0 -V

# process amplitude and sidescan
mbbackangle -I datalist.mb-1 \
        -A1 -A2 -Q -V -N87/86.0 -R50 -G2/85/1500.0/85/100
mbset -PAMPCORRFILE:datalist.mb-1_tot.aga
mbset -PSSCORRFILE:datalist.mb-1_tot.sga

# Process the data
mbm_multiprocess

# Filter the sidescan
mbfilter -Idatalistp.mb-1 -S2/5/3

##############################################################

# Generate first cut swath plots

# Navigation plot
mbm_plot -I datalistp.mb-1 -N0.05/0.25/1/0.1/0.1/0 -Pb -O Znav -V
Znav.cmd

# Bathymetry color shaded relief and navigation
mbm_plot -I datalistp.mb-1 -G2 -N0.25/0.25/1.0 -Pb -O Zbathshade -V
Zbathshade.cmd
convert -density 300 Zbathshade.ps -trim -quality 80 Zbathshade.jpg

mbm_plot -I datalistp.mb-1 -G1 -N0.25/0.25/1.0 -C -Pb -O Zbathcontour -V
Zbathcontour.cmd
convert -density 300 Zbathcontour.ps -trim -quality 80 Zbathcontour.jpg

mbm_plot -I datalistp.mb-1 -G4 -N0.25/0.25/1.0 -Pb -O Zamp -V
Zamp.cmd
convert -density 300 Zamp.ps -trim -quality 80 Zamp.jpg

mbm_plot -I datalistp.mb-1 -G5 -N0.25/0.25/1.0 -Pb -O Zss -V
Zss.cmd
convert -density 300 Zss.ps -trim -quality 80 Zss.jpg

##############################################################
#
# Generate first cut grid and plots
mbgrid -I datalist_log.mb-1 \
    -R-73.6397/-73.2850/39.4043/39.6558 \
    -E4/4 -A2 -F5 -N -C2 \
    -O ZTopoLog -V
mbgrdviz -I ZTopoLog.grd &

mbgrid -I datalist.mb-1 \
    -R-73.6397/-73.2850/39.4043/39.6558 \
    -E4/4 -A2 -F5 -N -C2 \
    -O ZTopoRaw -V
mbgrdviz -I ZTopoRaw.grd &

mbgrid -I datalistp.mb-1 \
    -R-73.6397/-73.2850/39.4043/39.6558 \
    -E4/4 -A2 -F5 -N -C2 \
    -O ZTopo -V
mbgrdviz -I ZTopo.grd &

gmt grdmath ZTopoRaw.grd ZTopoLog.grd SUB = ZTopoDiffRaw.grd
mbgrdviz -I ZTopoDiffRaw.grd &

gmt grdmath ZTopo.grd ZTopoRaw.grd SUB = ZTopoDiff.grd
mbgrdviz -I ZTopoDiff.grd &

mbm_grdplot -I ZTopo.grd \
        -O ZTopoSlopeNav \
        -G5 -D0/1 -A1 \
        -L"Kongsberg Multibeam Data Processing Example":"Topography (meters)" \
        -MGLfx4/1/41.33/5.0+l"km" \
        -MNIdatalistp.mb-1 \
        -Pc -V
ZTopoSlopeNav.cmd
convert -density 300 ZTopoSlopeNav.ps -trim -quality 80 ZTopoSlopeNav.jpg

# Topo slope map
mbm_grdplot -I ZTopo.grd \
        -O ZTopoSlope \
        -G5 -D0/1 -A1 \
        -L"Kongsberg Multibeam Data Processing Example":"Topography (meters)" \
        -MGLfx4/1/41.33/5.0+l"km" \
        -Pc -V
ZTopoSlope.cmd
convert -density 300 ZTopoSlope.ps -trim -quality 80 ZTopoSlope.jpg

# Raw Topo slope map
mbm_grdplot -I ZTopoRaw.grd \
        -O ZTopoRawSlope \
        -G5 -D0/1 -A1 \
        -L"Kongsberg Multibeam Data Processing Example":"Raw Topography (meters)" \
        -MGLfx4/1/41.33/5.0+l"km" \
        -Pc -V
ZTopoRawSlope.cmd
convert -density 300 ZTopoRawSlope.ps -trim -quality 80 ZTopoRawSlope.jpg

mbm_grdplot -I ZTopo.grd \
        -O ZTopoCont \
        -G1 -C -A1 -MCW0p \
        -L"Kongsberg Multibeam Data Processing Example":"Topography (meters)" \
        -MGLfx4/1/41.33/5.0+l"km" \
        -Pc -V
ZTopoCont.cmd
convert -density 300 ZTopoCont.ps -trim -quality 80 ZTopoCont.jpg

mbm_grdplot -I ZTopoDiff.grd \
        -O ZTopoDiffCont \
        -G1 -C1 -Z-20/20 -A1 -MCW0p \
        -L"Kongsberg Multibeam Data Processing Example - Recalculation Test":"Topography Difference (meters)" \
        -MGLfx4/1/41.33/5.0+l"km" \
        -Pc -V
ZTopoDiffCont.cmd
convert -density 300 ZTopoDiffCont.ps -trim -quality 80 ZTopoDiffCont.jpg

##############################################################
#
# Generate first cut amplitude mosaic and plot
mbmosaic -I datalistp.mb-1 \
    -R-73.6397/-73.2850/39.4043/39.6558 \
    -E4/4 -A3 -N -Y6 -F0.05 \
        -O ZAmpC -V
mbgrdviz -I ZTopo.grd -J ZAmpC.grd &

mbm_grdplot -I ZAmpC.grd \
        -O ZAmpCPlot \
        -G1 -W1/4 -D \
        -L"Kongsberg Multibeam Data Processing Example":"Amplitude (dB)" \
        -MGLfx4/1/41.33/5.0+l"km" \
        -Pc -V
ZAmpCPlot.cmd
convert -density 300 ZAmpCFPlot.ps -trim -quality 80 ZAmpCPlot.jpg
#
# Generate first cut sidescan mosaic and plot
mbmosaic -I datalistp.mb-1 \
    -R-73.6397/-73.2850/39.4043/39.6558 \
    -E4/4 -A4F -N -Y6 -F0.05 \
        -O ZSsCF -V
mbgrdviz -I ZTopo.grd -J ZSsCF.grd &

mbm_grdplot -I ZSsCF.grd \
        -O ZSsCFPlot \
        -G1 -W1/4 -D \
        -L"Kongsberg Multibeam Data Processing Example":"Amplitude (dB)" \
        -MGLfx4/1/41.33/5.0+l"km" \
        -Pc -V
ZSsCFPlot.cmd
convert -density 300 ZSsCFPlot.ps -trim -quality 80 ZSsCFPlot.jpg

############################################################
