#! /bin/bash
#
# MODULE:		julian_time_math_for_csv.sh
#
# PURPOSE:		To perform addition or subtraction to a comma-separated values
#	    		list of julian day timestamps
#
# COPYRIGHT:    (C) 2006-2021 by Eric Patton
#               This program is free software under the GNU General Public License (>=v2). 
#
# AUTHOR:		Eric Patton, Geological Survey of Canada (Atlantic)
#				<epatton AT nrcan dot gc dot ca>
#
# Last Modified: Jan 20, 2021
#
###############################################################################

# Capture CTRL-C and similar breaks.
trap 'echo -e "\n\nUser break! Exiting.\n" ; exit 1' 2 3 15

# Check if we have awk.
if [ ! -x "`which awk`" ] ; then
    echo "$SCRIPT: awk required, please install awk or gawk first" >&2
    exit 1
fi

# Check if we have bc.
if [ ! -x "`which bc`" ] ; then
    echo "$SCRIPT: bc required, please install bc first" >&2
    exit 1
fi

echo -n -e "\nAddition or Subtraction (a or s): "
read MODE

echo -n -e "\nAmount to modify timestamp by (in seconds): "
read VALUE

echo -n -e "\nEnter name of text file with list of timestamps in csv format: "
read LIST

LIST_LENGTH=`cat $LIST | awk 'BEGIN {FS=","} {print NF}'`
#echo "LIST_LENGTH is $LIST_LENGTH."

echo -e "\nProcessing $LIST_LENGTH timestamps...please standby..."

for  (( i=1; i<="$LIST_LENGTH"; i++ )) ; do

	
	TIMESTAMPS[$i]=`cat $LIST | cut -d"," -f${i}`

	# Check the length of the timestamp so that arithmetic is only performed on 
	# timestamps with 9 values. If there are less than 9 characters for the timestamp,
	# simply copy the current timestamp to the ANSWER array for printing.

	TIMESTAMP_LENGTH=${#TIMESTAMPS[$i]}

	if [ $TIMESTAMP_LENGTH -ne 9 ] ; then
		
		ANSWER[$i]=${TIMESTAMPS[$i]}
		continue
	fi

	#echo -e "Timestamp $i is TIMESTAMPS[i].\n"
	TIME_DAYS=`echo ${TIMESTAMPS[$i]:0:3}`
	TIME_HOURS=`echo ${TIMESTAMPS[$i]:3:2}`
	TIME_MINUTES=`echo ${TIMESTAMPS[$i]:5:2}`
	TIME_SECONDS=`echo ${TIMESTAMPS[$i]:7:2}`

	#echo -e "Days is $TIME_DAYS."
	#echo "Hours is $TIME_HOURS."
	#echo "Minutes is $TIME_MINUTES."
	#echo "Seconds is $TIME_SECONDS."


	TIME_ALL_SECONDS=`echo "$TIME_SECONDS + ($TIME_MINUTES * 60) + ($TIME_HOURS *3600) + ($TIME_DAYS * 86400)" | bc`

	#echo "Time in seconds is $TIME_ALL_SECONDS."


	if [ "$MODE" == "A" -o "$MODE" == "a" ] ; then
		FINAL_TIME_SECONDS=$(($TIME_ALL_SECONDS + $VALUE))
	else 	
		FINAL_TIME_SECONDS=$(($TIME_ALL_SECONDS - $VALUE))
	fi 

	FINAL_TIME_DAYS=`echo "$FINAL_TIME_SECONDS / 86400" | bc`
	HOUR_REMAINDER=`echo "$FINAL_TIME_SECONDS % 86400" | bc`
	FINAL_TIME_HOURS=`echo "$HOUR_REMAINDER / 3600" | bc`
	FINAL_TIME_MINUTES=`echo "(($FINAL_TIME_SECONDS % 86400) % 3600) / 60" | bc`
	FINAL_TIME_SECONDS=`echo "((($FINAL_TIME_SECONDS % 86400) % 3600) % 60)" | bc`

	#echo -e "\n\nFinal days is $FINAL_TIME_DAYS."
	#echo "Final hours is $FINAL_TIME_HOURS."
	#echo "Final minutes is $FINAL_TIME_MINUTES."
	#echo "Final seconds is $FINAL_TIME_SECONDS."


	LENGTH_HOURS=`echo $FINAL_TIME_HOURS | awk 'BEGIN {FS=""} {print NF}'`
	#echo -e "\nLength of FINAL_TIME_HOURS is $LENGTH_HOURS.\n"


	if [ "$LENGTH_HOURS" -eq 1 ] ; then
		FINAL_TIME_HOURS="0"$FINAL_TIME_HOURS 

	elif [ "$LENGTH_HOURS" -eq 0 ] ; then
		FINAL_TIME_HOURS="00"
	fi

	LENGTH_MINUTES=`echo $FINAL_TIME_MINUTES | awk 'BEGIN {FS=""} {print NF}'`
	#echo -e "\nLength of FINAL_TIME_MINUTES is $LENGTH_MINUTES.\n"

	if  [ "$LENGTH_MINUTES" -eq 1 ] ; then
		FINAL_TIME_MINUTES="0"$FINAL_TIME_MINUTES
		#echo -e "\nLength_Minutes is 1. Prepending a '0'."
		#echo "Final_Time_Minutes is now $FINAL_TIME_MINUTES."

	elif [ "$LENGTH_MINUTES" -eq 0 ] ; then
		FINAL_TIME_MINUTES="00"
		#echo -e "\nLength_Minutes is zero. Prepending a '00'."
		#echo "Final_Time_Minutes is now $FINAL_TIME_MINUTES."
	fi

	LENGTH_SECONDS=`echo $FINAL_TIME_SECONDS | awk 'BEGIN {FS=""} {print NF}'`
	#echo -e "\nLength of FINAL_TIME_SECONDS is $LENGTH_SECONDS."

	if [ "$LENGTH_SECONDS" -eq 1 ] ; then
		FINAL_TIME_SECONDS=`echo "0${FINAL_TIME_SECONDS}"`
		#echo -e "\nLength_Seconds is 1. Prepending a '0'."
		#echo "Final_Time_Seconds is now $FINAL_TIME_SECONDS."

	elif [ "$LENGTH_SECONDS" -eq 0 ] ; then
		FINAL_TIME_SECONDS="00"
		#echo -e "\nLength_Seconds is zero. Prepending a '00'."
		#echo "Final_Time_Seconds is now $FINAL_TIME_SECONDS."
	
	fi

	ANSWER[$i]=$FINAL_TIME_DAYS$FINAL_TIME_HOURS$FINAL_TIME_MINUTES$FINAL_TIME_SECONDS

	#echo -e "\n\n Answer is ${ANSWER[$i]}."

done

for (( i=1; i<="$LIST_LENGTH"; i++ )) ; do

	echo -n "${ANSWER[$i]}," > Modified_Timestamps.txt
	

done

echo -e "\nFinished."

exit 0
