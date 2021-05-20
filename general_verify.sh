#!/bin/bash

duplicity -v5 --no-encryption --allow-source-mismatch verify --compare-data file:///media/epatton/My_Passport1/EPATTON/GSCA/General_Forms_and_Documents /home/epatton/GSCA/General_Forms_and_Documents

exit 0
