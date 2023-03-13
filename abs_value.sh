#! /bin/bash

NUMBER=$1

echo ${NUMBER} | awk 'function abs(v) {v += 0; return v < 0 ? -v : v} {print abs($1)}'

exit 0
