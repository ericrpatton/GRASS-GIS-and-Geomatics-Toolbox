#!/bin/bash

while [ -z "$HUNDREDS" ] ; do
	read -p "Enter the Julian Day 'hundreds' value: " HUNDREDS
done

while [ -z "$START_TENS" ] ; do
	read -p "Enter the start of the sequence of 'tens' folder to create: " START_TENS
done

while [ -z "$END_TENS" ] ; do
	read -p "Enter the end of the sequence of 'tens' folders to create: " END_TENS
done


for TENS in `seq ${START_TENS} ${END_TENS}` ; do 
	for ONES in `seq 0 9` ; do 
		mkdir JD${HUNDREDS}${TENS}${ONES}
		mv -v *_${HUNDREDS}${TENS}${ONES}_* JD${HUNDREDS}${TENS}${ONES}
	done
done

exit 0
