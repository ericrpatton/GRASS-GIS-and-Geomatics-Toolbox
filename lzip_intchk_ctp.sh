#! /bin/bash

DIR=$(basename $(pwd))

parallel lzip -v ::: *
lz_integrity_check.sh
cd ../ 

echo -e "\n Creating tar package...\n"
tar cvf ${DIR}.tar ${DIR} 

echo ""

create_timestamp_proof.sh ${DIR}.tar

exit 0
