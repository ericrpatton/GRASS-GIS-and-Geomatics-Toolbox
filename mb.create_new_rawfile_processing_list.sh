#! /bin/bash

 
# Create a list of the raw .all files and the processed format files that exist
# in the current driectory.
ls -1 | grep -v 'p.mb59' | grep 'mb59$' | awk -F'.' '{print $1}' > mb59_listing.txt
ls -1 *.all | awk -F'.' '{print $1}' > raw_listing.txt

# List the files that are not common to both raw and processed formats, that is,
# the new files recently copied over that need processing.
comm -3 mb59_listing.txt raw_listing.txt | awk '{print $1".all"}' | tee new_raw_files.txt

# Make the processing directory if it doesn't already exist.
[[ -d new_raw_files ]] || mkdir new_raw_files

# Move the files identified for processing into the processing directory, then
# make a new datalist for these files. Preprocess these files, and move them
# back up into the main directory one level above. Remove the temporary lists
# and files created. Refresh the main processing datalist to include the
# newly­preprocessed files.
cat new_raw_files.txt | xargs -I {} mv {} new_raw_files
cd new_raw_files/
mbm_makedatalist -S.all -O new_raw_files.mb-1 -V
mbmakeplatform --swath=new_raw_files.mb-1 --output=platform.plf --verbose
mbpreprocess --input=new_raw_files.mb-1 --skip-existing --platform-file=platform.plf --verbose
mv *.all *mb59* ../
cd ../
rm -rf new_raw_files
rm new_raw_files.txt mb59_listing.txt raw_listing.txt

# There may be some already-processed files in this directory with a pmb59
# extension, so these need to be filtered out when writing a new datalist.
ls -1 | grep -v 'p.mb59' | grep 'mb59$' > list
mbdatalist -F-1 -U -I list > datalist.mb-1
rm list

exit 0
