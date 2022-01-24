#! /bin/bash

while [[ true ]] ; do

	echo -e "\n\nRunning rsync...\n"

	rsync -avhP /run/user/1000/gvfs/afp-volume:host=ffgg-nas-syn-3.local,user=anonymous,volume=Raw_data3/AMU_2021/Knudsen/AMU2021_Leg1/*.kea /media/epatton/My_Passport_4TB/Amundsen_2021804/Knudsen/KEA
	
	rsync -avhP /run/user/1000/gvfs/afp-volume:host=ffgg-nas-syn-3.local,user=anonymous,volume=Raw_data3/AMU_2021/Knudsen/AMU2021_Leg1/*.keb /media/epatton/My_Passport_4TB/Amundsen_2021804/Knudsen/KEB
	
	rsync -avhP --exclude-from=/home/epatton/amundsen_excludes.txt /run/user/1000/gvfs/afp-volume:host=ffgg-nas-syn-3.local,user=anonymous,volume=Raw_data3/AMU_2021/EM302/sisdata/AMU2021_Leg1_01/*.all /media/epatton/My_Passport_4TB/Amundsen_2021804/Multibeam/Rawdata

	rsync -avhP --exclude-from=/home/epatton/amundsen_excludes.txt /run/user/1000/gvfs/afp-volume:host=ffgg-nas-syn-3.local,user=anonymous,volume=Raw_data3/AMU_2021/EM302/sisdata/AMU2021_Leg1_01/*.wcd /media/epatton/My_Passport_4TB/Amundsen_2021804/Multibeam/Watercolumn

	rsync -avhP --exclude-from=/home/epatton/amundsen_excludes.txt /run/user/1000/gvfs/afp-volume:host=ffgg-nas-syn-3.local,user=anonymous,volume=Raw_data3/AMU_2021/NMEA_Logger/2021_Leg1/*_nmea.txt /media/epatton/My_Passport_4TB/Amundsen_2021804/Navigation/Amundsen_Science/Nmea_Logger

	rsync -avhP --exclude-from=/home/epatton/amundsen_excludes.txt /run/user/1000/gvfs/afp-volume:host=ffgg-nas-syn-3.local,user=anonymous,volume=Raw_data3/AMU_2021/Shiptracks/2021_Leg1/shiptrack*.txt /media/epatton/My_Passport_4TB/Amundsen_2021804/Navigation/Amundsen_Science/ShipTracks   

	rsync -avhP --exclude-from=/home/epatton/amundsen_excludes.txt /run/user/1000/gvfs/smb-share:server=shares.local,share=data/CNAV_GPS/2021_LEG_01/cnav_*.log /media/epatton/My_Passport_4TB/Amundsen_2021804/Navigation/Amundsen_Science/CNAV  
	
	echo -e "\n----------------------------------------------------------------------------------\n"

	echo -e "\nWaiting 30 minutes before re-executing..."
	timer.sh 1800
	echo  ""
done

exit 0
