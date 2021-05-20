#! /bin/bash

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

INPUT=$1
FORMAT=$2 

if [ -z "$FORMAT" ] ; then
	FORMAT=`mbformat -I $INPUT | grep MBIO | cut -d" " -f5`
fi

mbinfo -F$FORMAT -I$INPUT -V
echo -e "\nDisplaying results for file $INPUT for: "
countdown 00:00:12

exit 0
