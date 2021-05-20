#!/bin/bash

OUTPUT="plot.ps"

pscoast -R-129/-116/69/72 -Jm-122.5/71/1:2000000 -A100 -B10wesn -Dh -Gtan -Swhite -W0.7p -T-128/71.37/4 -Lf-125/69.35/70/200+lKilometres+jr -K > $OUTPUT

echo "-125.063529 71.191394" | psxy -J -R -B -Sa20p -W -Gred -V -O -K >> $OUTPUT

psbasemap -J -R -B -O -K >> $OUTPUT

grdcontour ../../../Generic/gebco_08_-141_60_-60_85.nc -Ccontour_intervals.txt -J -R -V -W1p,red -O >> $OUTPUT

ps2raster -A -Tg -V -P $OUTPUT
