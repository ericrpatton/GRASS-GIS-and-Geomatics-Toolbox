#! /bin/bash
<<<<<<< HEAD:get_grass_help.sh
# 
# get_grass_help.sh: Prints the help message for the Grass GIS program given as
# a parameter, without having to be in Grass.
#
# by Eric Patton
#
###############################################################################

=======
#
# Script: get_grass_help.sh
#
# Purpose: Prints the help info from a particular Grass program while outside of
# Grass itself.
#
###############################################################################
>>>>>>> 6390d1c0a8c2bfae2605e7cf7d05d207c4c7ce4f:gethelp.sh
SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT grass_program_name \n"
	exit 1
fi

INPUT=$1
grass --tmp-location EPSG:4326 --exec ${INPUT} --help

exit 0
