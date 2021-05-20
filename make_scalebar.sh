#! /bin/bash

UNITS="(m)"
TITLE="Elevation"
COLOUR=$1

psscale -C"${COLOUR}" -L -G-1100/1900 -Dx1c/10c+w12c/0.75c+jTC -Bx+l"${TITLE}" -By+l"${UNITS}" -P -V -F+gwhite > scalebar.ps

psconvert -A0.3c+gwhite+pthick -Tej scalebar.ps

exit 0
