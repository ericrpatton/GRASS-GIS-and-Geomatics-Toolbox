#! /bin/bash

for FILE in *.merged ; do
	if [ -f ${FILE}.7z ] ; then
		continue
	fi
	
	7za a ${FILE}.7z ${FILE}
done

exit 0
