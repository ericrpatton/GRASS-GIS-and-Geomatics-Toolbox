#! /bin/bash 
#
# mb.raw_datalist_dump_and_grid.sh - This script accepts an MB-System datalist
# as input, and generates the ancillary files (if needed), performs a
# rudimentary cleaning using mbclean, processes the data, exports an xyz file
# of the processed data, imports this xyz data into GRASS GIS, assigns the
# resultant raster a rainbow colour table, and createѕ a coloured,
# shaded-relief raster of this data, and exports the bathy grid and CSR grid
# as geotiffs.
# 
# Last modified: March 2, 2020
#
# CHANGELOG:	- Script created (01-25-2016)
#				- Added region calculation from mbinfo (01-26-2016)
#				- Added help message if no parameters are given (01-26-2016)
#				- Improved processing by using mbm_multi* programs to utilize
#				  multiple cores (01-26-2016)
#               - Allowed the explicit declaration of rawdata extension as a
#               parameter
#               - 
############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

SCRIPT=`basename $0`

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "-help" -o "$1" == "--help"  ] ; then
	echo -e "\nusage: $SCRIPT output.xyz [region (W/E/S/N)]\n"
	exit 1
fi

OUTPUT_XYZ=$1
REGION=$2 
RASTER=`basename $OUTPUT_XYZ .xyz`
CPUS=`lscpu | grep CPU\(s\): | awk '{print $2}'`

# Try to figure out what the MB-System file extension is
SUFFIX=`ls -1 --color=never *.mb* | head -n1 | awk -F'.' '{print $NF}'`
echo -e "\nMB-System filename suffix is $SUFFIX."
sleep 3

# Get datalist of the logged swath files
mbm_makedatalist -S${SUFFIX} -Odatalist_raw.mb-1
DATALIST=datalist_raw.mb-1

sleep 4

# Extract platform description from the logged data files (*.all files)
mbmakeplatform --swath=${DATALIST} --verbose --output=platform.plf

sleep 2

# Preprocess the data - extract asynchronous data (position, depth, heading, attitude)
# and merge with survey data; calculate bathymetry if necessary
mbpreprocess --input=${DATALIST} --platform=platform.plf --verbose

sleep 2

# For all multibeam sounder formats I've encountered (so far) that
# aren't mb58 format, the preprocessed files that get created by
# mbpreprocess will have the form *r.mb*.

if [ ${SUFFIX} != "mb58" ] ; then
	# We are dealing with a non-Kongsberg file format
	PREPROCESSED_SUFFIX="r.${SUFFIX}"
	echo -e "\nWe are dealing with a non-Kongsberg file format..."
else
	echo -e "\nWe are dealing with a Kongsberg file format..."
	PREPROCESSED_SUFFIX=".mb59"
fi

echo "Setting the preprocessed suffix to $PREPROCESSED_SUFFIX."
sleep 3

mbm_makedatalist -S${PREPROCESSED_SUFFIX} -P -V
mbdatalist -Z

# Get default svp
mbsvplist -P -V

#mbprocess -V

# The script mb.getinforegion will itself check whether the region info file
# mbinfo.txt exists or not, and will create one from the datalist if needed.
if [ -z "$REGION" ] ; then

	# No region parameter was given by the user, check whether mbinfo.txt
	# exists; if not, we scan the datalist to derive the region extents.
	# Running mb.getinforegion with no parameters will scan the region from
	# the datalist,  while running it a second time with the mbinfo.txt
	# parameter will print the output from that file.
	if [ -z "mbinfo.txt" ] ; then
		echo -e "\nNo region given by user...scanning datalist to calculate extents...\n"
		mb.getinforegion 
	fi

	REGION=`mb.getinforegion mbinfo.txt`
	echo "Set region to $REGION.\n"
	sleep 2

fi


mbclean -F-1 -I${DATALIST} -M1 -C75/2 -D0.01/0.2 -G0.8/1.2 -Z
mbm_multiprocess -I${DATALIST} -X${CPUS}
xyzdump.sh datalistp.mb-1 ${REGION} ${OUTPUT_XYZ}
import_xyz.sh ${OUTPUT_XYZ}
r.colors map=${RASTER}_${RES}m color=bof_unb
r.csr -mdt input=${RASTER}_${RES}m

exit 0
