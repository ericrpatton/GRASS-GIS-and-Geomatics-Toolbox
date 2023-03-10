#   ____                      _        ____  _          _ _ 
#  / ___| ___ _ __   ___ _ __(_) ___  / ___|| |__   ___| | |
# | |  _ / _ \ '_ \ / _ \ '__| |/ __| \___ \| '_ \ / _ \ | |
# | |_| |  __/ | | |  __/ |  | | (__   ___) | | | |  __/ | |
#  \____|\___|_| |_|\___|_|  |_|\___| |____/|_| |_|\___|_|_|
#                                                           
#  ____        _                  _       
# / ___| _ __ (_)_ __  _ __   ___| |_ ___ 
# \___ \| '_ \| | '_ \| '_ \ / _ \ __/ __|
#  ___) | | | | | |_) | |_) |  __/ |_\__ \
# |____/|_| |_|_| .__/| .__/ \___|\__|___/
#               |_|   |_|              
# 
### GRASS GIS ##################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

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


# Parse a GMT-style REGION string into its components
WEST=$(echo $REGION | cut -d'/' -f1)
EAST=$(echo $REGION | cut -d'/' -f2)
SOUTH=$(echo $REGION | cut -d'/' -f3)
NORTH=$(echo $REGION | cut -d'/' -f4)


# Find the absolte value of the west-east extent and the north-south extent
WEST_EAST_DIFF=$(abs_value.sh $(echo "$WEST - $EAST" | bc -l))
NORTH_SOUTH_DIFF=$(abs_value.sh $(echo "$NORTH - $SOUTH" | bc -l))


### MB-SYSTEM ################################################################ 

# Processed datalist checking
PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
[ ! -f "${PROCESSED_DATALIST}" ] && mbdatalist -F-1 -I ${DATALIST} -Z


DATALIST=${1}
PROC_DATALIST="$(basename $DATALIST .mb-1)p.mb-1"

# Standard command syntax for running mbgrid on a datalist
mbgrid -A${DATATYPE} -C2/1 -E${RES}/${RES}/meters! -F1 -I ${DATALIST} -R${MAX_WEST_LL}/${MAX_EAST_LL}/${MAX_SOUTH_LL}/${MAX_NORTH_LL} -O ${OUTPUT_ROOT} -V


### GENERIC SHELL COMMANDS #####################################################


# Syntax for producing numerically-sortable timestamps in filenames
date '+%F__%H-%M-%S'


# Command to run rsync recursively on the current directory, using wildcards,
# skipping directories that don't contain any matches:

rsync -ahrvP --dry-run --prune-empty-dirs --include='*.colr' --include='*/' --exclude='*' . destination_dir


### TIMER ### 
echo -e "\nWaiting ${MINUTES} minutes before re-executing..."
timer.sh ${PAUSE}
echo  ""


# Format for generic case statement
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


### DUMPING THE CONTENTS OF AN AWK ARRAY USING AN END STATEMENT

END { print CRUISE " " STREAK

for (i=0; i<STREAK; i++) {
	print TIMESTAMPS[i], " "LATITUDE[i], " "LONGITUDE[i]
}


### CREATING DATABASE INDICES FOR LOCATE ###
# Substite for the actual drive name below

updatedb -l 0 -o EP_ARCH_09.db -U . 


### GETTING THE ABSOLUTE VALUE OF NUMBER USING AWK ###

echo "-3" | awk 'function abs(v) {v += 0; return v < 0 ? -v : v} {print abs($1)}'


### PROMPTING THE USER FOR A RESPONSE ON COMMAND LINE BEFORE CONTINUING ***

while true; do
    read -p "Do you wish to continue this script? " yn
    case $yn in
        [Yy]* ) ;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
