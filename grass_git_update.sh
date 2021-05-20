#! /bin/bash

cd /usr/local/grass
git fetch --all
git merge upstream/master

exit 0
