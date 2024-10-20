#!/bin/bash
#
# minecraft-stop-server.sh - This script will be used to stop the minecraft sercvice locally.
# Version: 0.2
#
# By: Brian Nichols

# Check if minecraft service is currently running
echo "Checking if minecraft service is currently running" | ts
checkMinecraftService=$(ps -ef | grep bedrock_server | grep -v grep)
if [ -z "$checkMinecraftService" ]; then
	# Check if screen session is running
	echo "Minecraft service is already stopped. Checking if the minecraft-server screen session is currently running." | ts
	checkScreenSession=$(screen -ls | grep 'minecraft-server')
	if [ -z "$checkScreenSession" ]; then
		echo "Screen session minecraft-server is already stopped. Exiting." | ts
		exit
	else
		# Stopping screen session
		echo "minecraft-server screen session is still running. Since minecraft service isn't running, stopping the screen session then exiting" | ts
		screen -S minecraft-server -X quit
		exit
	fi
	
fi

##########################
# Since minecraft service is still running, performing steps to stop the minecraft service and the screeen session
# Announce in the minecraft world that the backup is starting soon and that the server will be going down

echo "Minecraft service is still running. Starting process to stop the service and screen session" | ts
echo "Messaging screen session that backup is starting in 5 mins" | ts
screen -S minecraft-server -X stuff 'say Backup starting in 5 mins. Server will be going DOWN''\015'

# Sleep for 4 minutes
echo "Sleeping for 4 mins" | ts
sleep 240

# Announce in the minecraft world that the backup is starting soon and that the server will be going down
echo "Messaging screen session that backup is starting in 1 min" | ts
screen -S minecraft-server -X stuff 'say Backup starting in 1 min. Server will be going DOWN''\015'

# Sleep for 55 seconds
echo "Sleeping for 55 secs" | ts
sleep 55

# Announce in the minecraft world that the backup is starting and that the server is going down
echo "Messaging screen session that backup is starting and server is going down" | ts
screen -S minecraft-server -X stuff 'say Backup starting. Server going down NOW''\015'

# Stop the mincecraft service
echo "Messaging screen session to take the minecraft world down" | ts
screen -S minecraft-server -X stuff 'stop''\015'

# Sleep for 1 min for the minecraft service to stop properly before moving on
echo "Sleeping for 1 min" | ts
sleep 60

# Stopping screen session
echo "Stopping the screen session" | ts
screen -S minecraft-server -X quit
