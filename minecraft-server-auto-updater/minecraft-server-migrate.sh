#!/bin/bash
#
# minecraft-server-migrate.sh - This script is used to perform the switch from the current minecraft version to the latest minecraft version.
# Version: 0.1
#
# By: Brian Nichols
#
# This script is designed to be called from another script:
# /home/brian/repos/minecraft/minecraft-server-auto-updater/minecraft-version-updater.py

# Create variable from argument
MCDIR=$1

# Clearing contents from previously used version-upgrade-backup directory
# NOTE: The directory "$MCDIR/version-upgrade-backup" is solely used via this script as a temporary location to hold the entire running minecraft server directory
echo "Clearing contents from previously used version-upgrade-backup directory" | ts
rm -r $MCDIR/version-upgrade-backup

# Moving the entire running minecraft server directory to the version-upgrade-backup directory
echo "Moving the entire running minecraft server directory to the version-upgrade-backup directory" | ts
mv $MCDIR/running $MCDIR/version-upgrade-backup

# Recreate the running minecraft server directory
echo "Recreate the running minecraft server directory" | ts
mkdir $MCDIR/running

# Unzip the latest minecraft version into the newly recreated running directory
echo "Unzipping the latest minecraft version into the newly recreated running directory" | ts
unzip /home/brian/maintenance/bedrock-server* -d $MCDIR/running > /dev/null

# Move the latest minecraft version zip download to the maintenance backup directory for later use if needed
echo "Move the latest minecraft version zip download to the maintenance backup directory for later use if needed" | ts
mv /home/brian/maintenance/bedrock-server* /home/brian/maintenance/minecraft-bedrock-server-versions/

# Copy the backed up minecraft worlds and settings from the version-upgrade-backup directory into the newly recreated running directory
echo "Copying the backed up minecraft worlds and settings from the version-upgrade-backup directory into the newly recreated running directory" | ts
cp -r $MCDIR/version-upgrade-backup/worlds/ $MCDIR/running
cp $MCDIR/version-upgrade-backup/allowlist.json $MCDIR/running
cp $MCDIR/version-upgrade-backup/server.properties $MCDIR/running
