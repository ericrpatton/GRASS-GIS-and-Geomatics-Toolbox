#! /bin/bash 
#
# mb.processed_datalist_xyzdump_and_grid.sh - This script accepts an MB-System
# processed datalist as input; it is expected that all preprocessing has
# already been done (i.e., datalist are ceated, mbpreprocess has been run. See
# unpack_and_preprocess.sh for details) and generates the ancillary files (if
# needed), performs a rudimentary cleaning using mbclean, processes the data,
# exports an xyz file of the processed data, imports this xyz data into GRASS
# GIS, assigns the resultant raster a rainbow colour table, and createѕ a
# coloured, shaded-relief raster of this data.
#
# This script is basically a clone of mb.gridtiles, except that it doesn't have
# to cope with managing memory and gridding regions; it just exports the full
# xyz dump and r.in.xyz handles importing the data into GRASS in chunks.
#
# Last modified: February 25, 2021
#
############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

SCRIPT=`basename $0`

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "-help" -o "$1" == "--help"  ] ; then
	echo -e "\nusage: $SCRIPT output_name.xyz [region (W/E/S/N)] [resolution]\n"
	exit 1
fi

OUTPUT_XYZ=$1
REGION=$2 
RES=$3

[[ -z ${RES} ]] && RES=100

# This is the format of output created by import_xyz.sh
RASTER="`basename ${OUTPUT_XYZ} .xyz`_${RES}m" 

CPUS=`lscpu | grep CPU\(s\): | awk '{print $2}'`

# The script mb.getinforegion will check whether the region info file
# mbinfo.txt exists, and if not, will create it.
[[ -z ${REGION} ]] && REGION=`mb.getinforegion`

#mbclean -F-1 -I${DATALIST} -M1 -C75/2 -D0.01/0.2 -G0.98/1.02 -Z
mbprocess -C${CPUS} -I datalist.mb-1 
xyzdump.sh datalistp.mb-1 ${REGION} ${OUTPUT_XYZ}
import_xyz.sh ${OUTPUT_XYZ} ${RES}

r.colors map=${RASTER} color=bof_unb
r.csr input=${RASTER}

exit 0
