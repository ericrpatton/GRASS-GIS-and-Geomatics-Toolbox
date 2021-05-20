#! /bin/bash

cd /usr/local/gmt5-dev/

sudo svn up
echo -e "\nSleeping 5 seconds...\n"
sleep 5

cd build/
sudo cmake ..
sudo make -j6
sudo make -j6 install

exit 0
