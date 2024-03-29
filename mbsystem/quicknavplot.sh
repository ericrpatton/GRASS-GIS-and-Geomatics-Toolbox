#! /bin/bash

# A quick script to plot MB-System datalist nav. It uses the processed datalist
# if it exists, otherwise, the raw datalist. The user can provide the desired
# geographical region as the second parameter, otherwise the region is
# caluculated from the datalist using mb.getinforegion.


SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

if [ "$#" -eq 0 -o "$#" -gt 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT DATALIST [REGION (w/e/s/n)]"
	echo "Use with the raw datalist.mb-1, *not* datalistp.mb-1!"
	exit 0
fi

DATALIST=${1}
PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
PLOTNAME="$(basename $DATALIST .mb-1)_Navplot"
CMD_NAME="${PLOTNAME}.cmd"
PSNAME="${PLOTNAME}.ps"
PDFNAME="$(basename $PSNAME .ps).pdf"

[[ ! -f "${PROCESSED_DATALIST}" ]] && mbdatalist -F-1 -I ${DATALIST} -Z

[[ -z ${2} ]] && REGION=$(mb.getinforegion $DATALIST) || REGION=$2 

echo -e "\nRegion is $REGION."
sleep 2

mbm_plot -F-1 -I ${PROCESSED_DATALIST} -N -R${REGION} -V -MGU/-0.75/-2 -T -MTW0.25 -MTDf -MTG222/184/135 -MTN1 -MTN2 -L" " -O ${PLOTNAME} 
bash ./${CMD_NAME} && sleep 2 && ps2pdf ${PSNAME} > ${PDFNAME}

[[ -f ${PSNAME} ]] && rm ${PSNAME}
[[ -f ${CMD_NAME} ]] && rm ${CMD_NAME}

exit 0
