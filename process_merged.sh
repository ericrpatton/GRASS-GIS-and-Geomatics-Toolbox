#! /bin/bash

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

#while [ -z "$JULIAN" ] ; do
#	read -p "Enter the Julian Day for this dataset: " JULIAN
#done	

JULIAN=Section

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

ls -1 *.merged > JD${JULIAN}_merged_10m.mb-1
#mbm_makedatalist -O JD${JULIAN}_merged_10m.mb-1
mbdatalist -F-1 -I JD${JULIAN}_merged_10m.mb-1 -O -V
#mbareaclean -F-1 -I JD${JULIAN}_merged_10m.mb-1 -D2 -V 
#mbprocess -F-1 -I JD${JULIAN}_merged_10m.mb-1 -V
#mbdatalist -F-1 -I JD${JULIAN}_merged_10m.mb-1 -P > JD${JULIAN}_merged_10mp.mb-1
echo -e "\nRunning mblist and exporting xyz file...\n"
mblist -F-1 -I JD${JULIAN}_merged_10m.mb-1 -D2 | proj -f '%0.3f' `g.proj -jf` +datum=WGS84 | awk '$1 != "*" || $2 != "*" {print $1, $2, -$3}' > JD${JULIAN}_merged_10m.xyz
g.align.xyz in=JD${JULIAN}_merged_10m.xyz fs=space res=10
echo ""
g.region -p
echo ""
r.in.xyz in=JD${JULIAN}_merged_10m.xyz fs=space output=JD${JULIAN}_merged_10m percent=20 --v --o
#r.csr -m JD${JULIAN}_merged_10m 
d.mon stop=x0
d.mon start=x0
d.rast JD${JULIAN}_merged_10m

exit 0

#Unused commands
#mbinfo -F-1 -I datalist.mb-1 -G -V
#mbclean -F-1 -I datalist.mb-1 -X5 (to nix the outer 5 beams on each side)
#mbgrid -A1 -E10/10/meters! -R`mb.getregion` -F1 -G4 -I datalistp.mb-1 -JUTM08N -OJD268_10m -V
