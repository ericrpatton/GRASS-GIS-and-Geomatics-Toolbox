#
############################################################################
#
# MODULE:        r.export_ll_tiles.sh for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       ...
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 November 25, 2021
# Last Modified: November 25, 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT rastername resolution \n"
	exit 0
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

RAST_INPUT=$1
VECT_INPUT="${RAST_INPUT}_vect"
RES=$2

# Use eval to capture Grass environment vaiables like the current MAPSET.
eval $(g.gisenv)
: ${MAPSET?}

# Check whether a vectorized version of the input raster exists; create one if
# not.
eval `g.findfile element=vector mapset=${MAPSET} file=${VECT_INPUT}` 
: ${file?}

VECT_CHECK=$file

g.region rast=${RAST_INPUT} res=${RES} -a

[[ -z ${VECT_CHECK} ]] && echo -e "\nNo vector outline found for input map $RAST_INPUT; running r.mapcalc to create one...\n" && r.mapcalc "${RAST_INPUT}_vect = if(${RAST_INPUT}, 1, null())" --o  && r.to.vect in=${RAST_INPUT}_vect output=${VECT_INPUT} type=area --o --v 

grass /home/epatton/Projects/LL_temp/PERMANENT/ --exec $(v.get_grid_divisions.sh)
v.proj --overwrite location=LL_temp mapset=PERMANENT input=LL_grid
g.rename vect=LL_grid,${VECT_INPUT}_LL_grid --o
v.select ain=${VECT_INPUT}_LL_grid bin=${VECT_INPUT} op=overlap output=${VECT_INPUT}_LL_tiles --o --v
v.category in=${VECT_INPUT}_LL_tiles op=print > tiles.txt

for CAT in $(cat tiles.txt) ; do 
	v.extract in=${VECT_INPUT}_LL_tiles type=area cats=${CAT} out=${VECT_INPUT}_LL_tiles_cat${CAT} --v --o 
done

for MAP in $(g.list type=vect pattern=${VECT_INPUT}_LL_tiles_cat*) ; do
	g.region vect=${MAP} res=${RES} -a
	r.mapcalc "${MAP} = ${RAST_INPUT}" --o --v 
	r.out.demgeotiff ${MAP}
done
	
exit 0
