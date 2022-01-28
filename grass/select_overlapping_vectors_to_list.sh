#! /bin/bash
# 
# A script to generate a list of vectors that overlaps a given input vector
# polygon. The second parameter is supposed to be a wildcard pattern of
# candidate vectors that are checked for overlap with the selection region.

SELECTION_REGION=$1
CANDIDATES=$2
TYPE="slope"

# Cleanup pre-existing files
if [ -f "${SELECTION_REGION}_${TYPE}.list" ] ; then
	rm ${SELECTION_REGION}_${TYPE}.list
fi


for MAP in `g.list type=vect pat=${CANDIDATES}` ; do 

	g.region vect=${MAP}
	v.select ainput=${SELECTION_REGION} atype=area binput=${MAP} btype=area output=${MAP}_selection op=overlap --o --q > /dev/null 2>&1
	AREAS=`v.info -t ${MAP}_selection | grep areas | cut -d'=' -f2`

	if [ ${AREAS} -gt 0 ] ; then
		echo "${MAP}" >> ${SELECTION_REGION}_${TYPE}.list
	fi
	
	g.remove --q type=vect name="${MAP}_selection" -f
		
done
	

# Cleanup

exit 0
