#! /bin/bash

while [ -z "$JULIAN" ] ; do
	read -p "Enter the Julian Day requested: " JULIAN
done	


SOURCE='~/.gvfs/data2013\ on\ mclure/022_Amundsen_Gulf/'
DESTINATION='/media/My_Passport1/Amundsen_2013804/'

cp -uv ${SOURCE}EM302/merged/${JULIAN}/*.merged  ${DESTINATION}Merged/${JULIAN}
cp -uv ${SOURCE}EM302/decnav/${JULIAN}.* ${DESTINATION}Nav
cp -uv ${SOURCE}EM302/raw/${JULIAN}/*.all.gz ${DESTINATION}Rawdata/${JULIAN}/
cp -uv ${SOURCE}EM302/raw/${JULIAN}/*.wcd.gz ${DESTINATION}Watercolumn/${JULIAN}/
cp -uv ${SOURCE}K320R/raw/${JULIAN}/* ${DESTINATION}Watercolumn/${JULIAN}/

exit 0
