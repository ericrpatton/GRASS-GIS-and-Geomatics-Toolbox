#! /bin/bash

PATTERN=${1}

parallel --eta -j8 lzip -v ::: ${PATTERN}

exit 0
