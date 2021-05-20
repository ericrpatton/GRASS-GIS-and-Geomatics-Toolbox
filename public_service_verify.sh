#!/bin/bash

duplicity -v5 --no-encryption --allow-source-mismatch verify --compare-data file:///media/epatton/My_Passport1/EPATTON/GSCA/Public_Service /home/epatton/GSCA/Public_Service

exit 0
