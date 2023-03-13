#! /bin/bash

cd ~
tar cjvf resource_file_backup_$(date +'%F').tar.bz2 .*rc

exit 0
