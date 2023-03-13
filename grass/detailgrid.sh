#! /bin/bash
#
#	A script to make a quick detailed Arc ASCII grid from MB-System multibeam
#	bathy, and import this bathy into GRASS, displaying it on a monitor.
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

OUTPUT=$1
RES=$2

while [ -z "$OUTPUT" ] ; do
	read -p "Please enter an output raster filename: " OUTPUT
done

while [ -z "$RES" ] ; do
	read -p "Please enter the output raster resolution: " RES
done

RAST_OUTPUT=`basename $OUTPUT .xyz`
echo -e "\nInut file name is $OUTPUT."
echo "RAST_OUTPUT is $RAST_OUTPUT." 
echo "RES is $RES."
echo ""

# mbgrid -A1 -E5/5/meters! -R`mb.getregion` -F1 -G4 -I datalist.mb-1 -JUTM08N -V -O "$OUTPUT"

echo -e "\nExporting xyz bathy at the following rate:\n"

if [ ! -f "$OUTPUT" ] ; then
	mblist -F-1 -I datalist.mb-1 -D2 -R`mb.getregion` | awk '{print $1, $2, -$3}' | proj $(g.proj -jf | sed 's/+type=crs//') | pv | awk '{print $1, $2, $3}' > ${OUTPUT}
fi

g.align.xyz in=${OUTPUT} fs=space res=${RES}

r.in.xyz in=${OUTPUT} fs=space output=${RAST_OUTPUT} percent=30 --v --o 
echo ""
r.colors map=${RAST_OUTPUT} color=bof_unb --v
r.csr -m map=${RAST_OUTPUT} passes=1
d.mon stop=x6
d.mon start=x6
g.region rast={$RAST_OUTPUT} res=${RES}
d.rast -o map=${RAST_OUTPUT}_fill_shade_comb

exit 0
