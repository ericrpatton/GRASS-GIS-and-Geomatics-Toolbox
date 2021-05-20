#! /bin/bash

grep CRP "$1" | awk -F'|' '{print $5, $6}' | sed 's/[TZ]/ /g' \
| awk '{print $1substr($2,1,2)substr($2,4,2)substr($2,7,2), substr($4,2,9), substr($5,3,9)}' \
| uniq
