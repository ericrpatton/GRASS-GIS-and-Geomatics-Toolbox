#! /bin/bash
#
# Runs mbdatalist -S in the current directory, on the default datalist, showing
# all locked files. Run mbdatalist -Y afterwards to remove any locked files.
#
# Created: March 26, 2021
# Modified: Oct 6, 2021
#
# by Eric Patton
#
##############################################################################

[[ -z ${1} ]] && DATALIST=datalist.mb-1 || DATALIST=$1

mbdatalist -F-1 -I ${DATALIST} -S | grep "Locked"

exit 0
