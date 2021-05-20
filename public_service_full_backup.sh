#!/bin/bash

test -x $(which duplicity) || exit 0

duplicity -v5 full --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/GSCA/Public_Service file:///media/epatton/My_Passport1/EPATTON/GSCA/Public_Service

duplicity -v5 remove-all-but-n-full 3 --force file:///media/epatton/My_Passport1/EPATTON/GSCA/Public_Service

exit 0
