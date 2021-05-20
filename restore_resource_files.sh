#! /bin/bash
#
# restore_resource_files.sh - A script to restore all modified resource files
# to their proper places in the $HOME directory.
#
# Last Modified: April 7, 2016
#
# CHANGELOG:  
# 
###############################################################################

echo -e "\nRestoring all RC files to home directory..."
echo ""
sleep 1

DIR="/media/epatton/My_Passport1/EPATTON/Resource_Files/"

cp -v ${DIR}.*rc /home/epatton/ 
cp -v ${DIR}terminalrc /home/epatton/.config/xfce4/terminal/
cp -v ${DIR}.mailcap ${DIR}.signature /home/epatton/ 
cp -v ${DIR}elinks.conf /home/epatton/.elinks/
echo ""

exit 0
