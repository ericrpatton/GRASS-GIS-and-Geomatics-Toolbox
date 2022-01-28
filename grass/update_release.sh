#! /bin/bash

function countdown
{
        local OLD_IFS="${IFS}"
        IFS=":"
        local ARR=( $1 )
        local SECONDS=$((  (ARR[0] * 60 * 60) + (ARR[1] * 60) + ARR[2]  ))
        local START=$(date +%s)
        local END=$((START + SECONDS))
        local CUR=$START

        while [[ $CUR -lt $END ]]
        do
                CUR=$(date +%s)
                LEFT=$((END-CUR))

                printf "\r%02d:%02d:%02d" \
                        $((LEFT/3600)) $(( (LEFT/60)%60)) $((LEFT%60))

                sleep 1
        done
        IFS="${OLD_IFS}"
        echo "        "
}

cd /usr/local/grass72_release
sudo svn update
echo -e "\n============================================\n"
echo "Pausing for: "
countdown 00:00:10

sudo make distclean
sudo /home/epatton/coderepo/grass70_configure_script.sh
echo -e "\n============================================\n"
echo "Pausing for: "
countdown 00:00:15

sudo make -j`nproc`
sudo make install

exit 0
