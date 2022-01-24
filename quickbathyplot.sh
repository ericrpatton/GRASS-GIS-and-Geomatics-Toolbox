#! /bin/bash

# A quick script to plot MB-System datalist shaded-relief bathymetry. It uses
# the process datalist if it exists, otherwise, the raw datalist. The user can
# provide the desired geographical region as the second parameter, otherwise the
# region is calculated from the datalist using mb.getinforegion.

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT DATALIST [REGION (w/e/s/n)]"
	exit 1
fi

DATALIST=${1}
PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
[[ ! -f "${PROCESSED_DATALIST}" ]] && mbdatalist -F-1 -I ${DATALIST} -Z

[[ -z ${2} ]] && REGION=$(mb.getinforegion $DATALIST) || REGION=$2 

mbm_plot -F-1 -I ${PROCESSED_DATALIST} -A5/315 -G2 -R${REGION} -V -MGU-0.75/-1.75 -T -MTW0.75 -MTDh -MTG222/184/135 -L" " -O "$(basename $PROCESSED_DATALIST .mb-1)_Bathyplot" 

exit 0
