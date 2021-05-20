#! /bin/bash

for FILE in *.all ; do
	if [ -f ${FILE}.bz2 ] ; then
		continue
	fi

	7za a ${FILE}.bz2 ${FILE}
done

exit 0
