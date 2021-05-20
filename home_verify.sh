#!/bin/bash

duplicity -v5 --no-encryption --allow-source-mismatch verify --compare-data file:///media/epatton/My_Passport1/EPATTON/GSCA/2020-2021 /home/epatton/GSCA/2020-2021

exit 0
