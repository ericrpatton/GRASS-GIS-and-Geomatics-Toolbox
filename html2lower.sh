#! /bin/sh

# A script to change all html formatting codes to lower case in the given input file.

cat $1 | sed -e "s/\(<\/*[A-Z]\+[0-9]*>\)/\L\1/g" -e "s/\(<A HREF\)/\L\1/g" 

exit 0
