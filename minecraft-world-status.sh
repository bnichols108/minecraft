#!/bin/bash
#
# minecraft-world-status.sh - This script will check the status of the live minecraft server (whether that be the primary or secondary), will send an email if a failure is found, and document it.
# Version: 0.2
#
# By: Brian Nichols

# Make sure to place this in crontab to run every 1 minute:
#* * * * * /bin/bash /home/brian/repos/minecraft/minecraft-world-status.sh >> /home/brian/maintenance/minecraft-world-status-logs/minecraft-world-status-`date +\%Y-\%m-\%d_\%H-\%M-\%S\%z`.log 2>&1


# As of right now, I'm going to make this script very static since it will be running on the current primary server. I will be reforming this later to run from both the primary and secondary servers



# 1. Check which server is the currently live server. Maybe check a static file that is updated from a different script? 
# I could also look into hosting this txt file in the cloud, so that if internet did go down on one of the servers, hopefully the other server can update it and each server can be checking it at all times. Just to
# get more cloud experience. Maybe S3?
#live_minecraft_server=`cat /home/brian/maintenance/live-minecraft-server.txt`

# 2. Check hostname of current server.
#echo Hostname is: $HOSTNAME
#echo Currently live minecraft server is: $currently_live_minecraft_server

# 3. Ping the internet
## if internet ping fails, update downtime doc. Also if this server running this script is also the live minecraft world, take minecraft down?

# 4. Ping the minecraft server
#ping -c 2 -t 1 192.168.0.101 > /dev/null 2> /dev/null
#if ping -c 4 Ubuntu-Minecraft-Server > /dev/null

# 5. Check for the bedrock_server running process
# Checking if minecraft-server-maintenance.sh script is running. If so, exiting.
if pgrep -af minecraft-server-maintenance.sh | grep -v vim > /dev/null
then
  echo "Minecraft server maintenance script currently in progress. Exiting" | ts
  exit 0
fi

# Checking if bedrock_server process is running. 
if pgrep bedrock_server > /dev/null 
then
  echo "Minecraft service is running. Exiting." | ts
else
  echo "Minecraft service is not running. Sending email" | ts
  sendmail -t < /home/brian/email-templates/minecraft_server_down.txt
fi


# 6. Check the port via external IP

# 7. Check the port via local IP 
#nc -vu 127.0.0.1 19132

