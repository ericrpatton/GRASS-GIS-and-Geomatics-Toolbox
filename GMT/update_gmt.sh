#!/bin/bash

countdown()
(
  IFS=:
  set -- $*
  secs=$(( ${1#0} * 3600 + ${2#0} * 60 + ${3#0} ))
  while [ $secs -gt 0 ]
  do
    sleep 1 &
    printf "\r%02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
    secs=$(( $secs - 1 ))
    wait
  done
  echo
)

cd /usr/local/gmt5-dev
sudo svn up
countdown 00:00:10

cd build
sudo cmake ..
echo -e "\n==================================================="
echo "Pausing script for: "
countdown 00:00:15

sudo make -j`nproc`
sudo make install

exit 0
