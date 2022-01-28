#! /bin/bash

LIST=$1

for MAP in `cat ${LIST}` ; do echo -e "\n\nChecking existance of map ${MAP}:"; g.list type=rast mapset=$(g.mapset -p) pattern="${MAP}*"; done

exit 0
