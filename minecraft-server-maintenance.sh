#!/bin/bash
#
# minecraft-server-maintenance.sh - This script will be used to run other scripts to perform maintenance on the Nighthawks minecraft server
# Version: 0.1
#
# By: Brian Nichols

# Make sure to place this in crontab to run every 6 hours:
#00 00,06,12,18 * * * /bin/bash /home/brian/repos/minecraft/minecraft-world-backup.sh >> /home/brian/maintenance/minecraft-world-backup-logs/minecraft-world-backup-`date +\%Y-\%m-\%d_\%H-\%M-\%S\%z`.log 2>&1

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
    /bin/bash /home/brian/repos/minecraft/minecraft-stop-server-testing.sh
    echo "Sleeping for 15 seconds" | ts
    sleep 15
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
    echo "Sleeping for 15 seconds" | ts
    sleep 15
    echo "Performing backup of minecraft world" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-world-backup.sh
    echo "Sleeping for 15 seconds" | ts
    sleep 15
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
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Minecraft world going down to perform version upgrade'
    echo "Stopping minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-stop-server.sh
    echo "Sleeping for 15 seconds" | ts
    sleep 15
    echo "Upgrading minecraft version" | ts
    
    echo "Sleeping for 15 seconds" | ts
    sleep 15
    echo "Starting minecraft service" | ts
    /bin/bash /home/brian/repos/minecraft/minecraft-start-server.sh
    echo "Sending message to Nighthawks discord" | ts
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Backup is completed and minecraft world is running again'
    minecraftVersion=`tail -1 /home/brian/maintenance/minecraft-server-auto-updater.log | cut -c 51-`
    /usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py "Minecraft version upgraded: $minecraftVersion"
    ;;

  *)
    echo "Unknown option: $1" | ts
    ;;
esac
