#! /bin/bash 
#
############################################################################
#
# MODULE:        mb.process_bckcst.sh 
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <Eric dot Patton at Canada dot ca>
# 
# PURPOSE:       Script for batch processing backscatter
#		 		 
# Last Modified: Oct 8, 2019
#
############################################################################

# The script is meant to be run from the project directory containing all of
# the julian day folders - be careful to check this first!

# Move all the .all files to the current directory so we can take advantage of
# a few mb-system scripts that will speed up processing
mv -v */*.all .
rm 9999.all

# We need a filename to test the mb-system format type against; might as well
# use the first one we find.
FILE_CANDIDATE=`ls -1 *.all |  head -n1`
FORMAT=`mbformat -I ${FILE_CANDIDATE} | grep "MBIO data format id" | cut -d':' -f2`

if [ $FORMAT -eq 56 ] ; then
	OUT_FORMAT=57

elif [ $FORMAT -eq 58 ] ; then
	OUT_FORMAT=59

else 
	echo "Check the input format of the file - we're aren't dealing with a Simrad format here."
	exit 1
fi

# OK, process that backscatter!
mbm_makedatalist -S.all -Odatalistl.mb-1
mbmakeplatform --swath=datalistl.mb-1 --output=platform.plf
mbpreprocess --input=datalistl.mb-1 --format=-1 --platform-file=platform.plf --verbose
mbm_makedatalist -S.mb${OUT_FORMAT} -P -V
mbdatalist -Z
mbbackangle -I datalist.mb-1 -A1 -Q -N87/86.0 -R50 -G1/85/1500.0/85/100 -V
mbset -PAMPCORRFILE:datalist.mb-1_tot.aga
mbm_multiprocess -I datalist.mb-1 -X8 -V
mbmosaic -I datalistp.mb-1 -A3 -N -Y2 -F0.05 -E2/2/meters! -JUTM20N -O BckSct_Y2_2m -V

exit 0
