#! /bin/bash 

echo -e "Job started at: ${START}\nJob finished at: $(date '+%c')" | mutt -s "Processing job finished!" eric.r.patton@pm.me 

exit 0
