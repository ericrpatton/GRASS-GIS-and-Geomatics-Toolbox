#! /bin/bash
#
# Runs mbdatalist -Y on the current directory, and on the default datalist,
# removing all locked files.
#
# Created: March 26, 2021
# Modified: March 26, 2021
#
# by Eric Patton
#
##############################################################################

[[ -z ${1} ]] && DATALIST=datalist.mb-1 || DATALIST=$1

mbdatalist -F-1 -I ${DATALIST} -Y | grep "Removing"

exit 0
