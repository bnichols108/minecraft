#!/bin/bash
#
# minecraft-stop-server.sh - This script will be used to stop the minecraft world locally.
# Version: 0.1
#
# By: Brian Nichols


checkserver=$(screen -ls | grep 'minecraft-server')
if [ -z "$checkserver" ]; then
	echo "Server is already off. Exiting."
	exit
fi

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
echo Server successfully turned off

# Stopping screen session
screen -S minecraft-server -X quit
