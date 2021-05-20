#! /bin/bash

ls -1 --color=never *.mb58 | awk '{print $1, "58", "1.0"}' > datalist.mb-1

exit 0

