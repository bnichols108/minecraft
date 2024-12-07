#!/bin/bash
#
# minecraft-stop-server.sh - This script will be used to stop the minecraft sercvice.
# Version: 0.3
#
# By: Brian Nichols

# Script optional arguments:
# $1 = amount of time before stopping the minecraft service
# $2 = reason for taking the server down

# Check if minecraft service is currently running
echo "Checking if minecraft service is currently running" | ts
checkMinecraftService=$(ps -ef | grep bedrock_server | grep -v grep)

# If minecraft service is not found, perform the following
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

# Create timeToStopService variable from first argument or use default of 5 mins
if [[ $1 ]]; then
	timeToStopService=$1
else
	timeToStopService=5

fi

# Create reasonToStopService variable from second argument or use default reason
if [[ $2 ]]; then
        reasonToStopService="$2"
else
        reasonToStopService="Unplanned Maintenance"

fi

# Announce in the minecraft world that the service will be going down soon
echo "Minecraft service is still running. Starting process to stop the service and screen session" | ts

# if $timeToStopService is greater than 1 minute, then first message the minecraft world about the time then count down to 1 minute left
if [[ "$timeToStopService" -gt 1 ]]; then
	echo "Messaging screen session for $timeToStopService minute reminder" | ts
	screenCompiledSentence="say Minecraft world going down in $timeToStopService minutes for reason: $reasonToStopService"
	screen -S minecraft-server -X stuff "$screenCompiledSentence"'\015'
	# do math do determine $timeToStopService - 1 min to see howw long we need to sleep for.
	timeToStopService=$((timeToStopService - 1))
	timeLeftToStopService=$((timeToStopService * 60))
	echo "Sleeping for $timeToStopService minutes ($timeLeftToStopService seconds)" | ts
	sleep $timeLeftToStopService
fi

# Announce in the minecraft world that the service will be going down in 1 minute
echo "Messaging screen session for 1 minute reminder" | ts
screenCompiledSentence="say Minecraft world going down in 1 minute for reason: $reasonToStopService"
screen -S minecraft-server -X stuff "$screenCompiledSentence"'\015'

# Sleep for 55 seconds
echo "Sleeping for 55 secs" | ts
sleep 55

# Announce in the minecraft world that the service will be going down
echo "Messaging screen session that minecraft world is going down now" | ts
screenCompiledSentence="say Minecraft world going down NOW"
screen -S minecraft-server -X stuff "$screenCompiledSentence"'\015'

# Stop the mincecraft service
echo "Messaging screen session to take the minecraft world down" | ts
screen -S minecraft-server -X stuff 'stop''\015'

# Sleep for 1 min for the minecraft service to stop properly before moving on
echo "Sleeping for 1 min" | ts
sleep 60

# Stopping screen session
echo "Stopping the screen session" | ts
screen -S minecraft-server -X quit
