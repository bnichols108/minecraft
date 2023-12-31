#!/bin/bash
#
# minecraft-world-backup.sh - This script will maintain backups on this server for both the primary and secondary drive.
# Version: 0.1
#
# By: Brian Nichols

# Check to ensure we have at least 56 backups, which should equal 14 days worth of backups (14 days x 4 backups per day for every 6 hours).
# if we have greater than or equal to 56 backups, then delete all minecraft-world-backup-*.tar.gz files older than 14 days.
if [ "`find /home/brian/minecraft-backup-primary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime -14 | wc -l`" -ge "56" ]; then
  echo Since we have enough backups, deleting all minecraft-world-backup-*.tar.gz files older than 14 days
  find /home/brian/minecraft-backup-primary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime +14 -delete
fi

# Announce in the minecraft world that the backup is starting, just in case they see performance degradation.
screen -S minecraft -X stuff 'say Backup starting soon''\015'

# Tar up the entire minecraft directory including the settings, world, etc and timestamp the tar file and place it in the primary backup location.
tar -zcvf "/home/brian/minecraft-backup-primary-drive/minecraft-world-backup/minecraft-world-backup-$(date '+%Y-%m-%d_%H-%M-%S%z').tar.gz" /home/brian/minecraft

# Take a copy of the new backup and place it on the secondary drive backup location.
cp 

screen -S minecraft -X stuff 'say Backup completed''\015'
