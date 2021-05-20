#! /bin/bash 

echo "Job started at: ${START}\nJob finished at: $(date '+%c')" | mutt -s "Processing job FAILED!" eric.r.patton@pm.me

exit 0
