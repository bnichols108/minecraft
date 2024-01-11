#!/bin/bash
#
# minecraft-world-status.sh - This script will check the status of the live minecraft server (whether that be the primary or secondary), will send an email if a failure is found, and document it.
# Version: 0.1
#
# By: Brian Nichols

# Make sure to place this in crontab to run every 1 minute:
#00 00,06,12,18 * * * /bin/bash /home/brian/repos/minecraft/minecraft-world-status.sh >> /home/brian/maintenance/minecraft-world-status-logs/minecraft-world-status-`date +\%Y-\%m-\%d_\%H-\%M-\%S\%z`.log 2>&1


# As of right now, I'm going to make this script very static since it will be running on the current primary server. I will be reforming this later to run from both the primary and secondary servers



# 1. Check which server is the currently live server. Maybe check a static file that is updated from a different script?
#currently_live_minecraft_server=`cat /home/brian/maintenance/currently-live-minecraft-server.txt`

# 2. Check hostname of current server.
#echo Hostname is: $HOSTNAME
#echo Currently live minecraft server is: $currently_live_minecraft_server

# 3. Ping the internet
## if internet ping fails, update downtime doc. Also if this server running this script is also the live minecraft world, take minecraft down?

# 4. Ping the minecraft server
#ping -c 2 -t 1 192.168.0.101 > /dev/null 2> /dev/null
#if ping -c 4 Ubuntu-Minecraft-Server > /dev/null

# 5. Check for the bedrock_server running process
# Adding another portion to check for time because this script is running while my other minecraft backup script is running, which sends a false positive (because the minecraft backup script currently 
# takes down the minecraft world). 

currenttime=$(date +%H:%M)
if [[ "$currenttime" > "00:00" && "$currenttime" < "00:10" ]] || [[ "$currenttime" > "06:00" && "$currenttime" < "06:10" ]] || [[ "$currenttime" > "12:00" && "$currenttime" < "12:10" ]] || [[ "$currenttime" > "18:00" && "$currenttime" < "18:10" ]];
then
  echo Not running the checks because the minecraft backup script is running. >> /home/brian/maintenance/minecraft-world-status-logs/minecraft-world-status-`date +\%Y-\%m-\%d_\%H-\%M-\%S\%z`.log 2>&1
  exit
fi

echo Bedrock server status:
if pgrep bedrock_server > /dev/null 
then
  echo Running
else
  echo Not running. Sending email. >> /home/brian/maintenance/minecraft-world-status-logs/minecraft-world-status-`date +\%Y-\%m-\%d_\%H-\%M-\%S\%z`.log 2>&1
  sendmail -t < /home/brian/email-templates/minecraft_server_down.txt
fi


# 6. Check the port via external IP

# 7. Check the port via local IP 
#nc -vu 127.0.0.1 19132

