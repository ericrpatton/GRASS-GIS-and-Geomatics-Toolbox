#! /bin/bash
#
# print_locate_db_path.sh : A simple scipt to write out an 'ls' listing of
# databases created by updatedb into a string that will be accepted by the
# 'locate' command. This script is used for telling locate what databse file to
# scan when searching for files.
#
# by Eric Patton
#
###############################################################################

ls -1 *.db | awk 'BEGIN {ORS=":"} {print $0}' | sed 's/:$//'

exit 0
