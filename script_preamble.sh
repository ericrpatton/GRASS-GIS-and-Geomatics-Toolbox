#! /bin/bash
############################################################################
# ____            _       _     ____                           _     _      
#/ ___|  ___ _ __(_)_ __ | |_  |  _ \ _ __ ___  __ _ _ __ ___ | |__ | | ___ 
#\___ \ / __| '__| | '_ \| __| | |_) | '__/ _ \/ _` | '_ ` _ \| '_ \| |/ _ \
# ___) | (__| |  | | |_) | |_  |  __/| | |  __/ (_| | | | | | | |_) | |  __/
#|____/ \___|_|  |_| .__/ \__| |_|   |_|  \___|\__,_|_| |_| |_|_.__/|_|\___|
#                  |_|                                                      
############################################################################
#! /bin/bash
#
# MODULE:        script_preamble.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at NRCan dash RNCan dot gc dot ca>
#
# PURPOSE:       This is a collection of script fragments that I use over and
# over, which should be sourced in scripts they are needed in.
#
# COPYRIGHT:     (c) 2023 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  January 27, 2022
# Last Modified:  February 18, 2022
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT XXXXXXXX \n"
	exit 0
fi

# Source make_filenames.sh, a script which handles all the filename wrangling
[[ -f /home/epatton/coderepo/make_filenames.sh ]] && set -- $INPUT && . /home/epatton/coderepo/make_filenames.sh

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

# Check if we have a particular program installed.

if [ ! -x "$(which awk)" ] ; then
	echo "$SCRIPT: awk required, please install awk or gawk first." 2>&1
	exit 1
fi

