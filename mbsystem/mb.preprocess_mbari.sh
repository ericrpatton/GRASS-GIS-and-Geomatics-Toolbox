############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        mb.preprocess
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To do some basic basic preprocessing and housekeeping for a
#				 directory bathymetry files. The rawdata format is gleaned by looking at the
# 				 extension of the first file in the directory, which may not always be correct.
# 				 A rawdata datalist is then created, along with a platform file (if possible),
# 				 and the mbpreprocess script is run on these files. Usually, in a directory
# 				 where there has been no previous processing done (including no mb-system
# 				 ancillary files created for the rawdata), the processed format will be the
# 				 second file listed in the directory after mbpreprocess completes (kludgey, I
# 				 know). A file extension is gleaned from this format, and new datalists
# 				 created.
# 
#				 Assuming all this works, you should be set up and ready to run other cleaning
# 				 and gridding scripts like mb.gridtiles.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 February 8, 2021
# Last Modified: February 21, 2021
#
#############################################################################

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

for DIR in $(echo -e "$(dirname $(find . -name version2 -prune -o -name *.mb* -print) | uniq)\n") ; do
	cd ${DIR}
	INPUT=$(ls -1 | head -n1)
	PRE_FORMAT=$(mbformat -K -I ${INPUT} | cut -d' ' -f2)
	mbm_makedatalist -S.mb${PRE_FORMAT} -O datalist_raw.mb-1 -V
	mbmakeplatform --swath=datalist_raw.mb-1 --output=platform.plf --verbose
	mbpreprocess --input=datalist_raw.mb-1 --platform-file=platform.plf --verbose
	PROCESSED_FILE=$(ls -1 | awk 'NR == 2 {print $1}')
	PROCESSED_FORMAT=${PROCESSED_FILE##*.}
	mbm_makedatalist -S.${PROCESSED_FORMAT} -V
	
	# Some older sonar formats will not generate a processed file format from
	# mbpreprocess, and hence the mbm_makedatalist call above will not produce a
	# new and different datalist from the input raw format. So we need to catch
	# that condition below, particularly because quicknav.sh and quickbathy.sh
	# depend on there being a file with datalist.mb-1 in the current directory.

	[[ ! -f "datalist.mb-1" ]] && cp datalist_raw.mb-1 datalist.mb-1

	mbdatalist -Z
	cd -
done

exit 0
