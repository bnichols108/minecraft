#!/bin/bash
#
# minecraft-start-server.sh - This script will be used to start the minecraft world locally.
# Version: 0.1
#
# By: Brian Nichols

checkserver=$(screen -ls | grep 'minecraft-server')
if [ "$checkserver" ]; then
        echo "Server is already running. Exiting"
        exit
fi

# Bring up the minecraft world
echo Creating screen session
screen -dmS minecraft-server
sleep 1

echo change to the running minecraft server directory
screen -S minecraft-server -X stuff 'cd /home/brian/minecraft/running/''\015'
sleep 1

echo Messaging screen session to start the minecraft world
screen -S minecraft-server -X stuff 'LD_LIBRARY_PATH=. /home/brian/minecraft/running/bedrock_server''\015'
sleep 1

echo Server started
