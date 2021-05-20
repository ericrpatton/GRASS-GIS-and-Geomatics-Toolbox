#! /bin/bash

INPUT=$1

awk -F, -v FILE=$INPUT '

BEGIN { i=0

	while ((getline < FILE) > 0) {
		array_number[i]=$1
		array_text[i]=$2
		array_teens[i]=$3
		i++
	}
close(FILE)
}

END { for (j=0 ; j<=i ; j++)
		print array_number[j], array_teens[j], array_text[j]
	}
	
' $INPUT

exit 0
