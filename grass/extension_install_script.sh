#! /bin/bash

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

g.extension extension=g.copyall
g.extension extension=g.rename.many
g.extension extension=g.compare.md5
g.extension extension=g.proj.all
g.extension extension=g.proj.identify
g.extension extension=v.label.sa

exit 0
