#! /bin/bash
#
# mbgr.sh: A shorthand for running mb.gridtiles -p datalist.mb-1 in the current
# directory, along with a few convenient helper scripts.
# and mbgrdviz together.
#
# Created: March 26, 2021
# Modified: February 8, 2022
# by Eric Patton
#
##############################################################################

export START=$(date +%_c)
clear ; time mb.gridtiles -p region=$(mb.getregion) res=30 && job_finished_text.sh 

exit 0
