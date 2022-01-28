#! /bin/bash


[[ -z "$GISBASE" ]] && echo "You must be in GRASS GIS to run this program." && exit 1

n=1

if [[ "$#" -eq 0 ]] ; then

	while [[ true ]] ; do
		read -p "Enter an raster filename: " INPUT
		[[ -z "$INPUT" ]] && break || INPUT[n]=$INPUT && n=$((n + 1))
	done
else

fi

LIST_LENGTH=$(("${#INPUT[@]}" -1 ))
echo "There are $LIST_LENGTH members in array INPUT."

# For testing purposes:
#for i in "${INPUT[@]}"; do echo "$i"; done
#
#exit 0
