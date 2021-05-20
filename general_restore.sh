#! /bin/bash

rm -rfv /home/epatton/GSCA/General_Forms_and_Documents
sleep 1.5

duplicity -v8 --allow-source-mismatch --progress --force --no-encryption file:///media/epatton/My_Passport1/EPATTON/GSCA/General_Forms_and_Documents /home/epatton/GSCA/General_Forms_and_Documents

exit 0 

