#! /bin/bash

ls -1 --color=never *.mb59 | awk '{print $1, "59", "1.0"}' > datalist.mb-1

exit 0


