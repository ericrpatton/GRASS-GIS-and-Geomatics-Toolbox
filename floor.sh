#! /bin/bash

# Rounds decimal portions of numbers up to the next whole integer.

INPUT=$1
echo ${INPUT} | awk '

{
	if ($1 < 0){
		if(int($1) == $1 )
			print int($1)
		else
			print int(($1)-1)
}
	else
		print int($1)
}'

exit 0
