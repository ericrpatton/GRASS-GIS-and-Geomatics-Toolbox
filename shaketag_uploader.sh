#! /bin/bash

SCRIPT=`basename $0`

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

case "$#" in 

	0) read -p "Enter the average amount of wait time in minutes: " SLEEP_MIN_AVG
	;;

	1) SLEEP_MIN_AVG=$1
	;;

	*) echo -e "\n$SCRIPT: Error: program syntax is shaketag_uploader.sh wait_in_minutes"
	   exit 1
	;;
esac

SLEEP_SEC_AVG=$(echo "scale=0 ; $SLEEP_MIN_AVG * 60" | bc -l)
SLEEP_SEC_MIN=$(($SLEEP_SEC_AVG - 1200)) # -20 minutes
SLEEP_SEC_MAX=$(($SLEEP_SEC_AVG + 1200)) # +20 minutes

MOUSE_SLEEP=1.8

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

while [ true ] ; do 
	
	# The plus icon
	xdotool mousemove 355 1000 click 1
	sleep ${MOUSE_SLEEP}

	# Click the Upload a file dialog box
	xdotool mousemove 416 897 click 1
	sleep ${MOUSE_SLEEP}

	# Select the Discord_Card folder
	xdotool mousemove 481 387 click 1
	sleep ${MOUSE_SLEEP}
	
	# Click 'Open'
	xdotool mousemove 1442 891 click 1
	sleep ${MOUSE_SLEEP}

	# Click 'Upload'
	xdotool mousemove 1153 655 click 1

	PAUSE=`shuf -i ${SLEEP_SEC_MIN}-${SLEEP_SEC_MAX} -n1` 

	MINUTES=$(echo "scale=1; $PAUSE / 60" | bc -l)
	echo -e "\nWaiting ${MINUTES} minutes before re-executing..."
	timer.sh ${PAUSE}
	echo  ""

done

exit 0
