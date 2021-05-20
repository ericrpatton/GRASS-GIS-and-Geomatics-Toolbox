#! /bin/bash

while [ -z "$JULIAN" ] ; do
	read -p "Enter the Julian Day for this dataset: " JULIAN
done

gunzip -v *.gz
mkdir -v temp_processing
mv *.all temp_processing
cd temp_processing
mbm_makedatalist
mbm_copy -F59 -I datalist.mb-1 -V
rm -v *.all
rm datalist.mb-1
mbm_makedatalist -O JD${JULIAN}_10m.mb-1
mbdatalist -F-1 -I JD${JULIAN}_10m.mb-1 -O -V
mbareaclean -F-1 -I JD${JULIAN}_10m.mb-1 -D2 -M -V 
mbprocess -F-1 -I JD${JULIAN}_10m.mb-1 -V
rm *.mb-1
mv * ../
cd ../
rm -rfv temp_processing

exit 0
