#! /bin/bash

rm -rfv /home/epatton/GSCA/2020-2021
sleep 1.5

duplicity -v8 --allow-source-mismatch --progress --force --no-encryption file:///media/epatton/My_Passport1/EPATTON/GSCA/2020-2021 /home/epatton/GSCA/2020-2021

exit 0 
