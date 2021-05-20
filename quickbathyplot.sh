#! /bin/bash

# A quick script to plot MB-System datalist shaded-relief bathymetry. It uses
# the process datalist if it exists, otherwise, the raw datalist.

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT [REGION (w/e/s/n)]"
	exit 1
fi

[[ -z ${1} ]] && REGION=$(mb.getinforegion) || REGION=$1

[[ -f datalistp.mb-1 ]] && DATALIST="datalistp.mb-1" || DATALIST="datalist.mb-1"

mbm_plot -F-1 -I ${DATALIST} -G2 -R${REGION} -V -MGU/-0.75/-1.75 -T -MTW/0.75 -MTDf -MTG -L" " -O "$(basename `pwd`)_Bathyplot" -B3 

exit 0
