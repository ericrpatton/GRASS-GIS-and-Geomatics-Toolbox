#! /bin/bash

rm -rfv /home/epatton/GSCA/Public_Service
sleep 1.5

duplicity -v8 --allow-source-mismatch --progress --force --no-encryption file:///media/epatton/My_Passport1/EPATTON/GSCA/Public_Service /home/epatton/GSCA/Public_Service

exit 0 

