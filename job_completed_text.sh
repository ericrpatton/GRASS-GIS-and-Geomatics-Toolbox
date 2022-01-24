#! /bin/bash 

echo -e "Job started at: ${START}\nJob completed at: $(date '+%c')" | mutt -s "Processing job completed!" eric.r.patton@pm.me 

exit 0
