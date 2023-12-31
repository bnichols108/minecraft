#!/bin/bash
#
# minecraft-world-backup.sh - This script will maintain backups on this server for both the primary and secondary drive.
# Version: 0.2
#
# By: Brian Nichols

# Variables:
#minecraft-world-backup-primary-dir=/home/brian/minecraft-backup-primary-drive/minecraft-world-backup/
#minecraft-world-backup-secondary-dir=/home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/

# Make sure to place this in crontab to run every 6 hours:
# 00 00,06,12,18 * * *

# Primary drive backup cleanup
# Check to ensure we have at least 56 backups, which should equal 14 days worth of backups (14 days x 4 backups per day for every 6 hours).
# if we have greater than or equal to 56 backups within the last 14 days, then delete all minecraft-world-backup-*.tar.gz files older than 14 days.
if [ "`find /home/brian/minecraft-backup-primary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime -14 | wc -l`" -ge "56" ]; 
then
  echo Since we have enough backups, deleting all minecraft-world-backup-*.tar.gz files older than 14 days from the primary drive backup
  find /home/brian/minecraft-backup-primary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime +14 -delete
else
  echo Not enough backups on the primary drive backup, so not deleting any backups.
fi

# Secondary drive backup cleanup
# Check to ensure we have at least 56 backups, which should equal 14 days worth of backups (14 days x 4 backups per day for every 6 hours).
# if we have greater than or equal to 56 backups within the last 14 days, then delete all minecraft-world-backup-*.tar.gz files older than 14 days.
if [ "`find /home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime -14 | wc -l`" -ge "56" ]; then
  echo Since we have enough backups, deleting all minecraft-world-backup-*.tar.gz files older than 14 days from the secondary drive backup
  find /home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime +14 -delete
else
  echo Not enough backups on the secondary drive backup, so not deleting any backups.
fi

# Announce in the minecraft world that the backup is starting, just in case they see performance degradation.
echo Messaging screen session that backup is starting
screen -S minecraft -X stuff 'say Backup starting''\015'

echo Messaging screen session to hold the save
screen -S minecraft -X stuff 'save hold''\015'

echo sleeping 15 secs for the save hold
sleep 15

# Tar up the entire minecraft directory including the settings, world, etc and timestamp the tar file and place it in the primary backup location.
echo Creating backup
tar -zcvf "/home/brian/minecraft-backup-primary-drive/minecraft-world-backup/minecraft-world-backup-$(date '+%Y-%m-%d_%H-%M-%S%z').tar.gz" /home/brian/minecraft

# Take a copy of the new backup on the primary drive and place it on the secondary drive backup location.
echo Copying backup to secondary drive
cp -p "`ls -dtr1 /home/brian/minecraft-backup-primary-drive/minecraft-world-backup/* | tail -1`" "/home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/"

echo Messaging screen session to resume the save
screen -S minecraft -X stuff 'save resume''\015'

# Announce in the minecraft world that the backup is starting, just in case they see performance degradation.
echo Messaging screen session that backup is complete
screen -S minecraft -X stuff 'say Backup completed''\015'
