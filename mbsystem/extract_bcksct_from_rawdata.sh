##############################################################################
#
# extract_bcksct_from_rawdata.sh	
#
# Script to extract backscatter from ṙaw multibeam data. No cleaning or
# filtering of the data is performed, only a backangle amplitude correction.
#
# Credit: David Caress, MBARI
#
# Date: Nov.8th, 2019
#
##############################################################################

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

SUFFIX=$1
DIRMODE=$2

# DIRMODE is acting as a flag to turn on directory scanning; on means through
# one level of subdirectories of rawdata files. Any other value means create a
# list of rawfiles from the current directory.

if [ ${DIRMODE} == "ON" -o ${DIRMODE} == "on" ] ; then
	ls -1f */*${SUFFIX} > list

else
	ls -1f *${SUFFIX} > list
fi

mbdatalist -F-1 -I list > datalistl.mb-1

# Get datalist of the logged swath files (*.all suffix)
#mbm_makedatalist -S${SUFFIX} -Odatalistl.mb-1

# Extract platform description from the logged data files (*.all files)
mbmakeplatform --swath=datalistl.mb-1 --verbose --output=platform.plf

# Preprocess the data - extract asynchronous data (position, depth, heading, attitude)
# and merge with survey data; calculate bathymetry if necessary
mbpreprocess --input=datalistl.mb-1 --platform=platform.plf

# Determine the MBIO format of the raw file format
RAWFILE=`head -n1 list`
RAW_FORMAT=`mbformat -I ${RAWFILE} | grep "MBIO data format id" | cut -d':' -f2 | awk '{print $1}'`

if [ ${RAW_FORMAT} -eq 56 ] ; then
	PROC_FORMAT=57
elif ${RAW_FORMAT} -eq 58 ] ; then
	PROC_FORMAT=59
fi


# Get datalist of raw *.mb59 files
mbm_makedatalist -S.mb${PROC_FORMAT} -P -V
mbdatalist -F-1 -I datalist.mb-1 -Z

# Process amplitude and sidescan
mbbackangle -I datalist.mb-1 -A1 -A2 -Q -V -N87/86.0 -R50 -G2/85/1500.0/85/100
mbset -PAMPCORRFILE:datalist.mb-1_tot.aga

# Process the data
mbm_multiprocess -I datalist.mb-1 -X8 -V

# Export backscatter mosaic, using a 3x spline interpolation fill on output grid
mbmosaic -I datalistp.mb-1 -A3 -C3 -N -Y2 -F0.05 -E2/2/meters! -JUTM20N -O BckSct_Y2_2m -V

# cleanup
rm -v list

exit 0
