#!/bin/bash
#
# minecraft-server-maintenance.sh - This script will be used to run other scripts to perform maintenance on the Nighthawks minecraft server
# Version: 0.1
#
# By: Brian Nichols

# Make sure to place this in crontab to run every 6 hours:
# 00 00,06,12,18 * * * . /home/brian/.bashrc; /bin/bash /home/brian/repos/minecraft/minecraft-server-maintenance.sh "backup" >> /home/brian/maintenance/minecraft-world-backup-logs/minecraft-world-backup-`date +\%Y-\%m-\%d_\%H-\%M-\%S\%z`.log 2>&1

# Call the script like this:
# Argument1 will be the case action

case $1 in

  stop)
    echo "Running stop case" | ts
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Minecraft world is stopping'
    echo "Stopping minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-stop-server.sh
    ;;

  start)
    echo "Running start case" | ts
    echo "Starting minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-start-server.sh 
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Minecraft world has been started'
    ;;

  restart)
    echo "Running restart case" | ts
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Minecraft world restarting'
    echo "Stopping minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-stop-server.sh
    echo "Sleeping for 5 seconds" | ts
    sleep 5
    echo "Starting minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-start-server.sh
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Minecraft world restart completed'
    ;;
  
  backup)
    echo "Running backup case" | ts
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Minecraft world is stopping to perform a backup'
    echo "Stopping minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-stop-server.sh
    echo "Sleeping for 5 seconds" | ts
    sleep 5
    echo "Performing backup of minecraft world" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-world-backup.sh
    echo "Sleeping for 5 seconds" | ts
    sleep 5
    echo "Starting minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-start-server.sh
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Backup is completed and minecraft world is running again'
    ;;

  os-updates)
    echo "Running os-updates case" | ts
    echo "Performing OS updates and reboot if required" | ts
    ;;

  upgrade-check)
    echo "Running upgrade-check case" | ts
    echo "Checking if a new minecraft version is available" | ts
    ;;

  upgrade)
    echo "Running upgrade case" | ts
    echo "Checking if there is a new verison of minecraft server" | ts
    newVersionAvailable=`/usr/bin/python3 /home/brian/repos/minecraft/minecraft-server-auto-updater/minecraft-version-check-for-latest.py`
    if [[ "$newVersionAvailable" == "false" ]]; then
	echo "Already the latest version. Nothing to update. Exiting" | ts
	exit
    elif [[ "$newVersionAvailable" == "error" ]]; then
    	echo "There was an error with determining if a new Minecraft version is available. Exiting." | ts
	exit
    elif [[ "$newVersionAvailable" == "true" ]]; then
    	echo "There is a new Minecraft version available. Upgrading." | ts
    else
	echo "Received unknown value. Value is: $newVersionAvailable. Exiting" | ts
	exit
    fi
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'There is a new minecraft version available. Minecraft world going down to perform version upgrade'
    echo "Stopping minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-stop-server.sh
    echo "Sleeping for 5 seconds" | ts
    sleep 5
    echo "Performing backup of minecraft world" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-world-backup.sh 
    echo "Sleeping for 5 seconds" | ts
    sleep 5
    echo "Upgrading minecraft version" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/minecraft-server-auto-updater/minecraft-version-updater.py
    echo "Starting minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-start-server.sh
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Minecraft version upgraded and Minecraft world is running again'
    currentMinecraftVersion=`tail -1 /home/brian/maintenance/minecraft-server-versioning.log | cut -d ' ' -f 10`
    previousMinecraftVersion=`tail -1 /home/brian/maintenance/minecraft-server-versioning.log | cut -d ' ' -f 8`
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py "@everyone Minecraft server version upgraded from $previousMinecraftVersion to $currentMinecraftVersion"
    ;;

  *)
    echo "Unknown option: $1" | ts
    ;;
esac
