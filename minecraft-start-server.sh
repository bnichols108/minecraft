#!/bin/bash
#
# minecraft-start-server.sh - This script will be used to start the minecraft service locally.
# Version: 0.2
#
# By: Brian Nichols

# Check if minecraft service is currently running
echo "Checking if minecraft service is currently running" | ts
checkMinecraftService=$(ps -ef | grep bedrock_server | grep -v grep)
if [ "$checkMinecraftService" ]; then
	# Since minecraft service is already running, the screen session should also be running. So nothing to do. Exiting
        echo "Minecraft service is already running. Which means screen session is also running. Nothing to do. Exiting." | ts
	exit
else
        # Check if screen session is already running
	echo "Minecraft service is not running. Checking if screen session is running" | ts
	checkScreenSession=$(screen -ls | grep 'minecraft-server')
        if [ -z "$checkScreenSession" ]; then
		echo "Screen session not running. Starting screen session" | ts
		screen -dmS minecraft-server -L -Logfile /home/brian/maintenance/minecraft-server-live-log.log
		sleep 1
	else
		echo "Screen session already running. Moving to next steps to start the minecraft service" | ts
        fi
fi


##########################
# Since minecraft service isn't running, performing steps to start the minecraft service
echo "Messaging screen session to cd to the minecraft world directory" | ts
screen -S minecraft-server -X stuff 'cd /home/brian/minecraft/running/''\015'
sleep 1

echo "Messaging screen session to start the minecraft service" | ts
screen -S minecraft-server -X stuff 'LD_LIBRARY_PATH=. /home/brian/minecraft/running/bedrock_server''\015'
sleep 1

echo "Minecraft service started" | ts
