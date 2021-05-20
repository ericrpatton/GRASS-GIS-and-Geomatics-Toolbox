#! /bin/bash

rename 's/ /_/g' *.flac
for FILE in *.flac ; do 
	flac -d ${FILE}
	BASE=`basename ${FILE} .flac`
	WAV="${BASE}.wav" 
	lame -h -b320 ${WAV} 
done 

rm -v *.wav

exit 0
