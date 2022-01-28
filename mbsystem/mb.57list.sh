#! /bin/bash

ls -1 --color=never *.mb57 | awk '{print $1, "57", "1.0"}' > datalist.mb-1

exit 0
