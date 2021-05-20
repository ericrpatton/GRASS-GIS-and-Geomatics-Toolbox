for FILE in JD*.txt ; do OLDDAY=`echo $FILE | awk -F. '{print substr($1,3,2)}'`;  NEWDAY=$(($OLDDAY + 212));  mv -i $FILE JD${NEWDAY}.txt; done
