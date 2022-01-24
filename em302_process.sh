#!/bin/bash
########################################################################################################
#
# TITLE: em302_process.sh
# AUTHOR: Jean-Guy Nistad
# 
# Copyright (C) 2015  Jean-Guy Nistad
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################################################

###
# Main processing script for the Kongsberg EM302 multibeam data on board CCGS Amundsen Data
#
# Required programs:
#         - MB-System version 5.4.22.20
#         - ImageMagick
###

_MERGE_NONE=0
_MERGE_FULL=1
_MERGE_PART=2
_VERBOSE=0

#
# merge_edits() $DATALIST $MERGE_OPTION - Merge bathymetry data from .gsf files produced from CARIS HIPS & SIPS with .all files
#
merge_edits() {
    # Create the gsf datalist produced from CARIS HIPS & SIPS
    [ $_VERBOSE -eq 1 ] && printf "Creating the gsf datalist...\n"
    ls -1 $DIR_DATA_GSF | grep '.gsf$' | awk '{print $1 " 121 1.000000"}' > $DIR_DATA_GSF/$DATALIST_GSF

    # Compare the listing of .mb59 files and .gsf files
    [ $_VERBOSE -eq 1 ] && printf "Comparing the .mb59 and .gsf file listing...\n"
    cat $DIR_DATA_MB59/$1 | awk -F '.' '{print $1}' > mb59_filenames
    cat $DIR_DATA_GSF/$DATALIST_GSF | awk -F '.' '{print $1}' > gsf_filenames
    
    # Identify the common .mb59 and .gsf files and make a filename listing (with no extension)
    comm -12 mb59_filenames gsf_filenames > mb59_gsf_common 
    
    # Identify the missing .gsf files
    comm -23 mb59_filenames gsf_filenames > gsf_missing
    if [ -s "gsf_missing" ]
    then
	printf "Missing .gsf file(s)! Consider editing in CARIS HIPS & SIPS and exporting a .gsf for the following files:\n"
	cat gsf_missing | awk '{print $1 ".gsf"}'
    fi

    if [ $2 -eq $_MERGE_FULL  ]; then
	# Create the merge gsf script
	[ $_VERBOSE -eq 1 ] && printf "Creating the mbcopy script file...\n"
	touch $MERGE_GSF_SCRIPT | printf "#!/bin/bash\n\n" > $MERGE_GSF_SCRIPT
	cat mb59_gsf_common | awk -v dir_mb59=$DIR_DATA_MB59 -v dir_gsf=$DIR_DATA_GSF \
				  '{print "mbcopy -F59/59/121 -I " dir_mb59 "/" $1 ".mb59 -M " dir_gsf "/" $1 ".gsf -O " dir_mb59 "/" $1 "f.mb59\n" \
                                      "rm " dir_mb59 "/" $1 ".mb59\n" \
                                      "mv " dir_mb59 "/" $1 "f.mb59 " dir_mb59 "/" $1 ".mb59"}' >> $MERGE_GSF_SCRIPT

	# run the merge gsf script
	[ $_VERBOSE -eq 1 ] && printf "Running the mbcopy script file...\n"
	chmod +x $MERGE_GSF_SCRIPT
	source $MERGE_GSF_SCRIPT

	# Remove the merge gsf script
	rm $MERGE_GSF_SCRIPT
	
    elif [ $2 -eq $_MERGE_PART  ]; then
	# Create the make esf script
	[ $_VERBOSE -eq 1 ] && printf "Creating the script to make esf files...\n"
	touch $MAKE_ESF_SCRIPT | printf "#!/bin/bash\n\n" > $MAKE_ESF_SCRIPT
	cat mb59_gsf_common | awk -v dir_mb59=$DIR_DATA_MB59 -v dir_gsf=$DIR_DATA_GSF \
				  '{print "mbgetesf -F121 -I " dir_gsf "/" $1 ".gsf -O " dir_mb59 "/" $1 ".mb59.esf"}' >> $MAKE_ESF_SCRIPT

	# run the make esf script
	[ $_VERBOSE -eq 1 ] && printf "Running the script to make esf files...\n"
	chmod +x $MAKE_ESF_SCRIPT
	source $MAKE_ESF_SCRIPT

	# Remove the make esf script
	rm $MAKE_ESF_SCRIPT
    fi

    # Clean up the temporary listings
    rm mb59_filenames gsf_filenames gsf_missing mb59_gsf_common
}


#
# convert_all() $MERGE_OPTION - Convert all .all files to generate mb59 files
#
convert_all() {
    printf "\n\n%s UTC: Converting all Simrad all files in directory %s\n\n" $(date --utc +%Y%m%d-%H%M%S) $DIR_DATA_ALL

    # Verify the validity of the merge option
    if ! [[ $1 =~ ^[0-2]+$ ]]; then
	printf "Merge value M is not in range! Possible values are 0, 1 and 2. Aborting...\n"
	exit 1
    fi
    
    # Create the .all datalist
    printf "Creating the Simrad all datalist...\n"
    ls -1 $DIR_DATA_ALL | grep '.all$' | grep -v '9999' | awk '{print $1 " 058 1.000000"}' > $DIR_DATA_ALL/$DATALIST_ALL

    # Make sure the .mb59 destination directory exists. If not, create it.
    if [ ! -d $DIR_DATA_MB59 ]; then
	printf "No directory %s found. Creating it...\n" $DIR_DATA_MB59
	mkdir $DIR_DATA_MB59
    else
	# Check that the directory is empty. If not, clean it.
	if [[ ! -z $(ls $DIR_DATA_MB59) ]]; then
	    printf "Cleaning the directory %s to start fresh...\n" $DIR_DATA_MB59
	    rm $DIR_DATA_MB59/*
	fi
    fi

    # Preprocess the Simrad all files and create unprocessed .mb59 files
    printf "Running mbkongsbergpreprocess...\n"
    [ $_VERBOSE -eq 1  ] && mbkongsbergpreprocess -C -F-1 -I $DIR_DATA_ALL/$DATALIST_ALL -D $DIR_DATA_MB59 -V || mbkongsbergpreprocess -C -F-1 -I $DIR_DATA_ALL/$DATALIST_ALL -D $DIR_DATA_MB59

    # Create the datalist for unprocessed mb59 files
    printf "Creating the mb59 datalist...\n"
    ls -1 $DIR_DATA_MB59 | grep '.mb59$' | awk '{print $1 " 59 1.000000"}' > $DIR_DATA_MB59/$DATALIST_MB59

    # Merge edits from CARIS HIPS & SIPS if requested
    if [ ! $1 -eq $_MERGE_NONE ]; then
	printf "Merging the mb59 files with gsf files with option M=%s...\n" $1
	merge_edits $DATALIST_MB59 $1
    fi

    # All done!
    printf "Done with converting Simrad all files.\n"
}


#
# update_all() $MERGE_OPTION - Convert new .all files not yet converted to mb59 files
#
update_all() {
    printf "\n\n%sUTC: Converting new Simrad all files in directory %s\n\n" $(date --utc +%Y%m%d-%H%M%S) $DIR_DATA_ALL

    # Create the .all datalist
    printf "Creating the Simrad all datalist...\n"
    ls -1 $DIR_DATA_ALL | grep '.all$' | grep -v '9999' | awk '{print $1 " 058 1.000000"}' > $DIR_DATA_ALL/$DATALIST_ALL

    # Make sure the .mb59 destination directory exists. If not, abort. If yes, create the .mb59 datalist
    if [ ! -d $DIR_DATA_MB59 ]; then
	printf "No directory %s found! Consider running the -C option instead. Aborting...\n" $DIR_DATA_MB59
    else
	# Compare the listing of Simrad all files and mb59 files
	[ $_VERBOSE -eq 1 ] && printf "Comparing the Simrad all and mb59 file listing...\n"
	cat $DIR_DATA_ALL/$DATALIST_ALL | awk -F '.' '{print $1}' > all_filenames
	cat $DIR_DATA_MB59/$DATALIST_MB59 | awk -F '.' '{print $1}' > mb59_filenames

	# Identify the missing .mb59 files
	comm -23 --nocheck-order all_filenames mb59_filenames > mb59_missing
	printf "The following Simrad all files have not been converted:\n"
	cat mb59_missing | awk '{print $1 ".all"}'
	printf "They will now be processed.\n"
	
	# Create a temporary .all update datalist
	printf "Creating the temporary update .all datalist...\n"
	cat mb59_missing | awk '{print $1 ".all 58 1.000000"}' > $DIR_DATA_ALL/$DATALIST_UPDATE_ALL

	# Preprocess the .all files and create unprocessed .mb59 files
	printf "Running mbkongsbergpreprocess..."
	mbkongsbergpreprocess -C -F-1 -I $DIR_DATA_ALL/$DATALIST_UPDATE_ALL -D $DIR_DATA_MB59

	# Create a temporary datalist for unprocessed .mb59
	printf "Creating the temporary update .mb59 datalist...\n"
	cat mb59_missing | awk '{print $1 ".mb59 59 1.000000"}' > $DIR_DATA_MB59/$DATALIST_UPDATE_MB59

	# Clean up
	rm all_filenames mb59_filenames mb59_missing

	# Merge edits from CARIS HIPS & SIPS
	merge_edits $DATALIST_UPDATE_MB59 $1

	# Update the unprocessed .mb59 datalist
	ls -1 $DIR_DATA_MB59/$DATALIST_MB59 $DIR_DATA_MB59/$DATALIST_UPDATE_MB59 | xargs cat >> $DIR_DATA_MB59/$DATALIST_MB59

	# Remove the update .all and .mb59 datalists
	rm $DIR_DATA_ALL/$DATALIST_UPDATE_ALL
	rm $DIR_DATA_MB59/$DATALIST_UPDATE_MB59
    fi

    
}


#
# process_mb59() - Create processed .mb59 files from the specified MB-system datalist
#
process_mb59() {
    printf "\n\n%s UTC: Processing the mb59 files in the %s MB-System datalist.\n\n" $(date --utc +%Y%m%d-%H%M%S) $DIR_DATA_MB59/$DATALIST_MB59
    
    # Apply the bathymetric edits
    [ $_VERBOSE -eq 1 ] && printf "Applying bathymetric edits...\n"
    cat $DIR_DATA_MB59/$DATALIST_MB59 | awk -F '.' '{print $1}' > mb59_filenames
    touch mbset.sh | printf "#!/bin/bash\n\n" > mbset.sh
    cat mb59_filenames | awk -v dir_mb59=$DIR_DATA_MB59 '{print "mbset -PEDITSAVEMODE:1 -PEDITSAVEFILE:" dir_mb59 "/" $1 ".mb59.esf -I " dir_mb59 "/" $1 ".mb59"}' >> mbset.sh
    chmod +x mbset.sh
    source mbset.sh
    
    # Apply the tide
    # TO BE COMPLETED
    
    # Process the mb59 files and create processed mb59 files
    [ $_VERBOSE -eq 1 ] && printf "Creating processed mb59 files...\n"
    mbprocess -I $DIR_DATA_MB59/$DATALIST_MB59
   
    # Create the mb59 datalist of processed mb59 files
    [ $_VERBOSE -eq 1 ] && printf "Creating the processed mb59 datalist...\n"
    printf "\$PROCESSED\n%s\n" $DATALIST_MB59 > $DIR_DATA_MB59/$DATALISTP_MB59

    # Cleanup
    rm mbset.sh
    rm mb59_filenames
}





#
# em302_process_help() - Display some basic help about em302_process
#
em302_process_help() {
    bU=$(tput smul) # begin underline font
    eU=$(tput rmul) # end underline font
    bB=$(tput smso) # begin bold font
    eB=$(tput rmso) # end bold font

    cat << EOF
Program em302_process
Version 2.0

em302_process is a high-level bash shell script used to process EM302 multibeam bathymetry data
collected by the Canadian ice-breaker CCGS Amundsen. em302_process is a front-end to MB-System.
When run, em302_process will create processed mb59 files containing both bathymetry and backscatter
data. The bathymetry data can be merged from an external gsf file produced by a third-party software.

Usage: ./${0##*/} [-C -D -H -M${bU}mode${eU} -P -U -V]

     -C          Convert all Simrad all files
     -D          Print the content of the parameters file
     -H          Display this help and exit
     -M          Bathymetry merge option
     -P          Process bathymetry
     -U          Update all unconverted Simrad all files
     -V          Apply verbose mode for increased verbosity

For a detailed description, type: ${bB}man ./em302_process.1${eB}
EOF
}


#
# print_parameters() - Prints the parameters.dat file
#
print_parameters() {
  if [ ! -f parameters.dat ]; then
      printf "Warning! No parameter file found. Make sure that the parameters.dat file exists in the current execution directory.\n"
      exit 1
  else
      cat parameters.dat
  fi
}



####################
# MAIN STARTS HERE #
####################

# Check if MB-System is properly installed
mbstatus=$(which mbinfo)
if [ -z $mbstatus ]; then
    printf "Could not call mbinfo! Please make sure MB-Sysem is properly installed\n"
    exit 1
fi

# Set the project metadata from the parameters.dat file
if [ ! -f parameters.dat ]; then
    printf "Warning! No parameter file found. Make sure that the parameters.dat file exists in the current execution directory.\n"
    exit 1
fi
chmod +x parameters.dat
source parameters.dat

# Default arguments
merge_arg=0

# Command flags
convert_all_flag=0
process_mb59_flag=0
update_flag=0

# Parse the command line
while getopts  ":CDHM:PUV" opt
do
    case $opt in
	C)
	    # Convert all Simrad all files
	    convert_all_flag=1;
	    ;;
	D)
	    # Print the parameters.dat file
	    print_parameters >&2
	    ;;
	
	H)
	    # Display some help
	    em302_process_help >&2
	    ;;
	M)
	    # Bathymetry merge option
	    merge_arg=$OPTARG;
	    ;;
	P)
	    # Process .mb59 files
	    process_mb59_flag=1;
	    ;;
	U)
	    # Convert only new Simrad all files since last conversion
	    update_flag=1;
	    ;;
	V)
	    # Enable verbose output mode
	    _VERBOSE=1
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
    esac
  
done #getopts

if [ $# -eq 0 ]; then
    # No option was passed: just display a useful message
    printf "To display the help, type %s -H\n" $0
else
    if [ $convert_all_flag -eq 1 ]; then
	# Convert all Simrad all files
	convert_all $merge_arg
    elif [ $update_flag -eq 1 ]; then
	# Update the unconverted Simrad all files with option M=$merge_arg
	update_all $merge_arg
    fi
    
    if [ $process_mb59_flag -eq 1 ]; then
	# Process all modified mb59 files
	process_mb59
    fi    
fi
