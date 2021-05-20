##############################################################
#
# Example processing of Kongsberg multibeam data in *.all files using tools
# mbmakeplatform and mbpreprocess
##############################################################
#
# David W. Caress
# 8 February 2019
#
# Get datalist of the logged swath files (*.all suffix)
mbm_makedatalist -S.all -Odatalistl.mb-1
#
# Extract platform description from the logged data files (*.all files)
mbmakeplatform --swath=datalistl.mb-1 --verbose --output=platform.plf
#
# Preprocess the data - extract asynchronous data (position, depth, heading, attitude)
# and merge with survey data; calculate bathymetry if necessary
mbpreprocess --input=datalistl.mb-1 --platform=platform.plf --verbose
#
# Get datalist of raw *.mb59 files
mbm_makedatalist -S.mb59 -P -V
mbdatalist -Z

# Get tide models and set for use by mbprocess
#mbotps -I datalist.mb-1 -M -D60.0 -V

# Get default svp
mbsvplist -P -V

# Process the data
mbprocess

# Edit bathymetry
# mbedit
mbeditviz -I datalist.mb-1

# Process the data
mbset -PSSRECALCMODE:1
mbprocess

# process amplitude and sidescan
mbbackangle -I datalist.mb-1 -A1 -A2 -Q -V -N87/86.0 -R50 -G2/85/1500.0/85/100
mbset -PAMPCORRFILE:datalist.mb-1_tot.aga
mbset -PSSCORRFILE:datalist.mb-1_tot.sga

# Process the data
mbprocess

# Filter the sidescan
mbfilter -Idatalistp.mb-1 -S2/5/3 -V

mblist -I 0015_20110601_114736_TGT.all -OT#XYZ -MA > listmb58.txt

mblist -I 0015_20110601_114736_TGT.mb59 -OT#XYZ -MA > list59.txt

##############################################################
#
# Generate first cut grid and plots
mbgrid -I datalist.mb-1 -A2 -F5 -N -C2 -O ZTopoRaw -V
mbgrdviz -I ZTopoRaw.grd &

mbgrid -I datalistp.mb-1 -A2 -F5 -N -C2 -O ZTopo -V
mbgrdviz -I ZTopo.grd &

mbm_grid -I 0015_20110601_114736_TGTp.mb59 -A2 -F5 -N -C2 -O ZTopo -V




mbm_grdplot -I ZTopo.grd \
-O ZTopoSlopeNav \
-G5 -D0/1 -A1 \
-L"Kongsberg Multibeam Data Processing Example":"Topography (meters)"
\
-MGLfx4/1/-20.85/0.5+l"km" \
-MNIdatalistp.mb-1 \
-Pc -MIE300 -MITg -V
ZTopoSlopeNav.cmd

mbm_grdtiff -I ZTopo.grd \
-O ZTopoSlopeNav \
-G5 -D0/1 -A1 -V
ZTopoSlopeNav_tiff.cmd

# Topo slope map
mbm_grdplot -I ZTopo.grd \
-O ZTopoSlope \
-G5 -D0/1 -A1 \
-L"Kongsberg Multibeam Data Processing Example":"Topography (meters)"
\
-MGLfx4/1/-20.85/0.5+l"km" \
-Pc -MIE300 -MITg -V
ZTopoSlope.cmd

# Topo shade map
mbm_grdplot -I ZTopo.grd \
-O ZTopoShade \
-G2 -A1/090/05 \
-L"Kongsberg Multibeam Data Processing Example":"Topography (meters)"
\
-MGLfx4/1/-20.85/0.5+l"km" \
-Pc -MIE300 -MITg -V
ZTopoShade.cmd

mbm_grdplot -I ZTopo.grd \
-O ZTopoCont \
-G1 -C -A1 -MCW0p \
-L"Kongsberg Multibeam Data Processing Example":"Topography (meters)"
\
-MGLfx4/1/-20.85/0.5+l"km" \
-Pc -MIE300 -MITg -V
ZTopoCont.cmd

# Topo shade map
mbm_grd3dplot -I ZTopo.grd \
-O ZTopo3DShade \
-G2 -A1/090/05 \
-L"Kongsberg Multibeam Data Processing Example":"Topography (meters)"
\
-MGLfx4/1/-20.85/0.5+l"km" \
-Pc -MIE300 -MITg -V
ZTopo3DShade.cmd

##############################################################
#
# Generate first cut amplitude mosaic and plot
mbmosaic -I datalistp.mb-1 -A3 -N -Y6 -F0.05 \
-O ZAmpC -V
mbgrdviz -I ZTopo.grd -J ZAmpC.grd &

mbm_grdplot -I ZAmpC.grd \
-O ZAmpCPlot \
-G1 -W1/4 -D -S \
-L"Kongsberg Multibeam Data Processing Example":"Amplitude (dB)" \
-MGLfx4/1/-20.85/0.5+l"km" \
-Pc -MIE300 -MITg -V
ZAmpCPlot.cmd
#
# Generate first cut sidescan mosaic and plot
mbmosaic -I datalistp.mb-1 -A4F -N -Y6 -F0.05 \
-O ZSsCF -V
mbgrdviz -I ZTopo.grd -J ZSsCF.grd &

mbm_grdplot -I ZSsCF.grd \
-O ZSsCFPlot \
-G1 -W1/4 -D -S \
-L"Kongsberg Multibeam Data Processing Example":"Amplitude (dB)" \
-MGLfx4/1/-20.85/0.5+l"km" \
-Pc -MIE300 -MITg -V
ZSsCFPlot.cmd

############################################################
