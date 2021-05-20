#! /bin/bash 
#
############################################################################
#
# MODULE:        watch_and_process_nav.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <Eric dot Patton at Canada dot ca>
# 
# PURPOSE:       To watch a designated folder for new Regulus E files, and
#				 then run the daily processing scripts on them.
#
# COPYRIGHT:    (c) 2018 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
#							
# Date created: April 30, 2018
#
# Last Modified: April 30, 2018
#	by Author
#
############################################################################

SOURCE=/home/epatton/Hudson_2018041/Navigation

inotify-hookable -w ${SOURCE} -c 'dailynav.sh'



