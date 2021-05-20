#! /bin/bash

find -type f \( -name '*.esf*' -o -name '*.par' -o -name '*p.mb*' \) -print0 | xargs -0 -I '{}' rm -v {}

exit 0
