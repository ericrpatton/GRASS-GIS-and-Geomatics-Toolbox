#! /bin/bash

# An ugly hack to chop up navigation from Peter's Master Logger and extract out
# the corrected Trackpoint position for sidescan/Campod.

grep PROCESSED $1 | grep "Drop Camera" | awk -F'|' '{print $5, $6}' | sed 's/[TZ]/ /g' \
| awk '{print $1substr($2,1,2)substr($2,4,2)substr($2,7,2), substr($4,1,9), substr($5,1,10)}' \
| sed -e 's/^2009-09-07/250/' -e 's/^2009-09-08/251/' -e 's/^2009-09-09/252/' \
-e 's/^2009-09-10/253/' -e 's/^2009-09-11/254/' -e 's/^2009-09-12/255/' \
-e 's/^2009-09-13/256/' -e 's/^2009-09-14/257/' -e 's/^2009-09-15/258/' \
-e 's/^2009-09-16/259/' -e 's/^2009-09-17/260/' -e 's/^2009-09-18/261/' \
-e 's/^2009-09-19/262/' -e 's/^2009-09-20/263/' -e 's/^2009-09-21/264/' \
-e 's/^2009-09-22/265/' -e 's/^2009-09-23/266/' 
