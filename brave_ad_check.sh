#! /bin/bash
#
# brave_ad_check.sh: A script to automake mouse gestures on a Brave Browser to
# autoclick BAT Rewards ads. The script waits a random amount of time between
# 1-12 minutes before rerunning.
#
# Date Created: September 11, 2020
# Last Modified: February 18, 2021
#
##############################################################################

SCRIPT=`basename $0`

# How long the script should wait before running again.
PAUSE_MIN=20
PAUSE_MAX=720

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

while [ true ] ; do 
	
	COUNTER=$(($COUNTER + 1)) 
	echo -e "\nRunning Brave Ad check for the $COUNTER time..." 
	sleep 2
	NUMBER_OF_ROUNDS=`rolldice 1d5+2`
    echo -e "Running ${NUMBER_OF_ROUNDS}rounds of fake movements:\n"
	sleep 1

	# Move the mouse off of the menubar area so mouse wheel movements don't
	# get stuck.
	xdotool mousemove 1700 700

	sleep 1

	for (( EVENT_COUNTER=1; EVENT_COUNTER<= $NUMBER_OF_ROUNDS; EVENT_COUNTER++ )) ; do
		EVENT_TYPE=`shuf -i 1-5  -n1`

		case $EVENT_TYPE in
			1) # Scrollbar Up click
				DELAY=`shuf -i 100-600 -n1`
				REPEAT=`shuf -i 3-10 -n1`
				echo "Running ${REPEAT} fake up scrollbar clicks..."
				sleep 0.75 
				xdotool mousemove 1912 107 click --repeat ${REPEAT} --delay ${DELAY} 1
			;;

			2) # Scrollbar Down click
				DELAY=`shuf -i 100-600 -n1`
				REPEAT=`shuf -i 3-10 -n1`
				echo "Running ${REPEAT} fake down scrollbar clicks..."
				sleep 0.75 
				xdotool mousemove 1912 1025 click --repeat ${REPEAT} --delay ${DELAY} 1
			;;

			3) # Mouse Wiggling
				DELAY=`shuf -i 250-750 -n1`
				NUMBER_OF_WIGGLES=`rolldice 4d4+2`
				echo "Running ${NUMBER_OF_WIGGLES}fake mouse wiggles..."
				sleep 0.75 
				
				for (( WIGGLE=1; WIGGLE<=$NUMBER_OF_WIGGLES; WIGGLE++ )) ; do
					X=`shuf -i 50-1850 -n1`
					Y=`shuf -i 100-1000 -n1`

					WIGGLE_SLEEP=0.15
					xdotool mousemove ${X} ${Y} sleep ${WIGGLE_SLEEP}
				done
			;;

			4) # Mouse Wheel Scroll Up
			   # Add a little mouse wiggle prior to scrolling
			   xdotool mousemove 1700 700 
			   sleep 0.5
			  
			   NUMBER_OF_SCROLLING_ROUNDS=`shuf -i 3-10 -n1` 
			   REPEAT=`shuf -i 3-10 -n1`
			   DELAY=`shuf -i 50-300 -n1`
			   echo "Running ${REPEAT} fake mouse wheel up scrolls..."
			   sleep 0.75 

			   for (( SCROLL=1; SCROLL<=$NUMBER_OF_SCROLLING_ROUNDS; SCROLL++)) ; do
					xdotool click --repeat ${REPEAT} --delay ${DELAY} 4
			   done
			;;

			5) # Mouse Wheel Scroll Down
			   # Add a little mouse wiggle prior to scrolling
			   xdotool mousemove 1700 700 
			   sleep 0.5

			   NUMBER_OF_SCROLLING_ROUNDS=`shuf -i 3-10 -n1` 
			   REPEAT=`shuf -i 5-10 -n1`
			   DELAY=`shuf -i 50-300 -n1`
			   echo "Running ${REPEAT} fake mouse wheel down scrolls..."
			   sleep 0.75 

			   for (( SCROLL=1; SCROLL<=$NUMBER_OF_SCROLLING_ROUNDS; SCROLL++)) ; do
					xdotool click --repeat ${REPEAT} --delay ${DELAY} 5
			   done
			;;
		esac
		
		sleep 1 

	done
		
	# Now, hopeully we've tricked Brave and an ad is ready to be clicked!
	# Move the mouse to the upper right corner and click where the ad
	# would normally appear.
	#sleep 1
	#xdotool mousemove 1850 140 click 1
	echo "Done."

	PAUSE=`shuf -i ${PAUSE_MIN}-${PAUSE_MAX} -n1`
	echo -e "\nWaiting ${PAUSE} seconds before re-executing..."
	timer.sh ${PAUSE}
	echo "==============================================="
done

exit 0
