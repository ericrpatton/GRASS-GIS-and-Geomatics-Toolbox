#! /bin/bash
#
############################################################################
#
# MODULE:        MODULENAME for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       ...
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		  , 2021
# Last Modified:  , 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT XXXXXXXX \n"
	exit 1
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15



### MB-SYSTEM #######################################################

# Processed datalist checking
PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
[ ! -f "${PROCESSED_DATALIST}" ] && mbdatalist -F-1 -I ${DATALIST} -Z


DATALIST=${1}
PROC_DATALIST="$(basename $DATALIST .mb-1)p.mb-1"

# Standard command syntax for running mbgrid on a datalist
mbgrid -A${DATATYPE} -C2/1 -E${RES}/${RES}/meters! -F1 -I ${DATALIST} -R${MAX_WEST_LL}/${MAX_EAST_LL}/${MAX_SOUTH_LL}/${MAX_NORTH_LL} -O ${OUTPUT_ROOT} -V

####################################################################

# Syntax for producing numerically-sortable timestamps in filenames
date '+%F__%H-%M-%S'

# Using eval to populate variables
# The parameter expansion ${x:?} checks whether the variable x is set, and
# prints the error message after the question mark (if any) if x is not set or
# is null.
eval $(g.region -pg)
: ${w?} ${e?} ${s?} ${n?}

# Use eval to capture Grass environment vaiables like the current MAPSET.
eval $(g.gisenv)
: ${MAPSET?}

# Example for checking whether a Grass raster exists or not
eval `g.findfile element=cell mapset=$MAPSET file=${SHADE}` 
: ${file?}

SHADE_CHECK=$file

# Command to run rsync recursively on the current directory, using wildcards,
# skipping directories that don't contain any matches:

rsync -ahrvP --dry-run --prune-empty-dirs --include='*.colr' --include='*/' --exclude='*' . destination_dir

### TIMER ### 
echo -e "\nWaiting ${MINUTES} minutes before re-executing..."
timer.sh ${PAUSE}
echo  ""

case "$#" in

0) read -p "Enter name of navigation A-File to check: " AFILE 
read -p "Enter the cruise number: " CRUISE 

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

1) AFILE=$1 
read -p "Enter the cruise number: " CRUISE

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

2) AFILE=$1 ; CRUISE=$2 

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

3) AFILE=$1 ; CRUISE=$2 ; THRESHOLD=$3

;;

*) echo -e "\n$SCRIPT: Error: program syntax is: afile2nav.sh afile_name cruise_number time_threshold"
   echo -e "Only zero to three parameters are accepted.\n" 
   exit 1	
;;

esac

### READING a text file into an awk array in a BEGIN statement:

BEGIN { 

	COUNTER = 0 ; PREV_RECORD_TIME_ALL_SECONDS = 32000000 ; j=0

	# Read the values from each column of data into separate arrays
	
	while((getline < "filename.txt" ) > 0) {
		start_time[j]=$1
		end_time[j]=$2
		j++
		}
	close ("Amundsen_2021_SEGY_times.txt") 
}

