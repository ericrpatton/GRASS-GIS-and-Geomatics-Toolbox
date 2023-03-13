#! /bin/bash

for DRIVE in $(lsblk | awk '{print $7}' | grep EP) ; do cd ${DRIVE} ; update_locate_databases.sh ; done

exit 0
