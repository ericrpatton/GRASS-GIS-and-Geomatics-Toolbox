#!/bin/bash

if [ "$#" -eq 0 ] ; then
	echo -e "\nmultivol-tar.sh syntax: multivol-tar.sh dirname output_root vol_size\n"
	exit 1
fi

src_len=$(du -sb $1 | cut -f1)
echo "Source length is $src_len."
sleep 1

vol_count=$(($src_len/$3+1))
echo "vol_count is $vol_count."
sleep 1

printf "n $2-%d.tar\n" `seq 2 ${vol_count}` | tar -ML $(($3/1024)) -cvf $2-1.tar $1

exit 0
