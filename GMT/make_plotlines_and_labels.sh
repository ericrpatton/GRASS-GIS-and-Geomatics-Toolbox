#! /bin/bash

# This script is intended to create a 1x1-inch graticule on an A0 size paper, to
# assist in the manual positioning of map decorations and text when using GMT.
for NUM in `seq 0 19` ; do echo "0 $NUM" >> horizontal_plotlines.txt ; echo "42 $NUM" >> horizontal_plotlines.txt ; NUM=$(( $NUM + 1 )); done
for NUM in `seq 0 42`  ; do echo "$NUM 19" >> vert_plotlines.txt ; echo "$NUM 0" >> vert_plotlines.txt ; NUM=$(( $NUM + 1 )); done

# Make horizontal labels
for NUM in `seq 0 19` ; do echo "0 $NUM" >> horiz_plotline_labels.txt ; NUM=$(( $NUM + 1 )); done
for NUM in `seq 0 42`  ; do echo "$NUM 19" >> vert_plotline_labels.txt ; NUM=$(( $NUM + 1 )); done 

awk '{print $1, $2, NR}' horiz_plotline_labels.txt > tmp && mv tmp horiz_plotline_labels.txt
awk '{print $1, $2, NR}' vert_plotline_labels.txt > tmp && mv tmp vert_plotline_labels.txt

exit 0
