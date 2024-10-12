#!/bin/bash
#
# minecraft-world-backup.sh - This script will maintain backups on this server for both the primary and secondary drive.
# Version: 0.3
#
# By: Brian Nichols

# Make sure to place this in crontab to run every 6 hours:
#00 00,06,12,18 * * * /bin/bash /home/brian/repos/minecraft/minecraft-world-backup.sh >> /home/brian/maintenance/minecraft-world-backup-logs/minecraft-world-backup-`date +\%Y-\%m-\%d_\%H-\%M-\%S\%z`.log 2>&1

# Variables:
#minecraft_world_backup_primary_dir=/home/brian/minecraft-backup-primary-drive/minecraft-world-backup/
#minecraft_world_backup_secondary_dir=/home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/
s3_backup_bucket=s3://minecraft-nighthawks-backup
s3_backup_limit=56
archive_name="minecraft-world-backup-$(date '+%Y-%m-%d_%H-%M-%S%z').tar.gz"

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
#if [ "`find /home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime -14 | wc -l`" -ge "56" ]; then
#  echo Since we have enough backups, deleting all minecraft-world-backup-*.tar.gz files older than 14 days from the secondary drive backup
#  find /home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/ -type f -name "minecraft-world-backup-*.tar.gz" -mtime +14 -delete
#else
#  echo Not enough backups on the secondary drive backup, so not deleting any backups.
#fi

# Announce in the minecraft world that the backup is starting soon and that the server will be going down.
echo Messaging screen session that backup is starting in 5 mins
screen -S minecraft-server -X stuff 'say Backup starting in 5 mins. Server will be going DOWN''\015'

# Sleep for 4 minutes.
echo sleeping for 4 mins
sleep 240

# Announce in the minecraft world that the backup is starting soon and that the server will be going down.
echo Messaging screen session that backup is starting in 1 min
screen -S minecraft-server -X stuff 'say Backup starting in 1 min. Server will be going DOWN''\015'

# Sleep for 55 seconds.
echo sleeping for 55 secs
sleep 55

# Announce in the minecraft world that the backup is starting and that the server is going down.
echo Messaging screen session that backup is starting and server is going down
screen -S minecraft-server -X stuff 'say Backup starting. Server going down NOW''\015'

# Take the minecraft world down
echo Messaging screen session to take the minecraft world down
screen -S minecraft-server -X stuff 'stop''\015'

# Sleep for 1 min for the minecraft world to stop properly
echo sleeping for 1 min 
sleep 60

# Tar up the entire minecraft directory including the settings, world, etc and timestamp the tar file and place it in the primary backup location.
echo Creating backup
#tar -zcvf "/home/brian/minecraft-backup-primary-drive/minecraft-world-backup/minecraft-world-backup-$(date '+%Y-%m-%d_%H-%M-%S%z').tar.gz" /home/brian/minecraft
tar -zcvf "/home/brian/minecraft-backup-primary-drive/minecraft-world-backup/$archive_name" /home/brian/minecraft


# Take a copy of the new backup on the primary drive and place it on the secondary drive backup location.
#echo Copying backup to secondary drive
#cp -p "`ls -dtr1 /home/brian/minecraft-backup-primary-drive/minecraft-world-backup/* | tail -1`" "/home/brian/minecraft-backup-secondary-drive/minecraft-world-backup/"

# Bring up the minecraft world
echo Messaging screen session to start the minecraft world
screen -S minecraft-server -X stuff 'LD_LIBRARY_PATH=. /home/brian/minecraft/running/bedrock_server''\015'

# Cleaning up old backups from S3 if applicable
echo Cleaning up old backups from S3 if applicable
list_of_s3_backups=( $(aws s3 ls $s3_backup_bucket | awk '{print $4}') )

if [[ ${#list_of_s3_backups[@]} -ge $s3_backup_limit ]]; then
    echo "There are too many archives. Deleting oldest one."
    echo Deleting this backup from S3: ${list_of_s3_backups[0]}
    aws s3 rm $s3_backup_bucket/${list_of_s3_backups[0]}
else
    echo There is only ${#list_of_s3_backups[@]} backups, skipping backup cleanup for S3.
fi

# Uploading latest backup to S3
echo Uploading latest backup to S3
s3_upload_status=$(aws s3 cp /home/brian/minecraft-backup-primary-drive/minecraft-world-backup/$archive_name $s3_backup_bucket)

if [[ "$s3_upload_status" =~ "upload:" ]]; then
    echo S3 file upload successful
else
    echo Error occured while uploading archive to S3. Please investigate
fi

