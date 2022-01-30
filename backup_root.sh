rsync -avhzP --delete --log-file=/var/log/backup_daily.log --exclude-from=/home/epatton/coderepo/excludes  / /media/epatton/EP_ARCH_01/Daily

# -a, --archive               archive mode
# -v, --verbose
# -h, --human-readable        output numbers in a human-readable format
# -z, --compress              compress file data during the transfer 
# -P                          same as --partial --progress 
