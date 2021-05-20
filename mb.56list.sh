#! /bin/bash

ls -1 --color=never *.mb56 | awk '{print $1, "56", "1.0"}' > datalist.mb-1

exit 0
