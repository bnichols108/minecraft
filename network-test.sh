#!/bin/bash
#
# Script: network-test.sh 
#
# Description: This script will test multiple portions of the network 
#			   plus services that should be available. Will notify me of issues.
#
# By: Brian Nichols
#
# Version: 1

# Variables
IP_FILE=$(cat /home/shadower/scripts/external-ip/ipaddress.txt)

# Test internet connection
if ping -c 2 -t 10 8.8.8.8 > /dev/null 
then
	echo "Internet is working"
else
	echo "Internet is not working"
fi

# Test Minecraft port
if nc -z -w5 "$IP_FILE" 25565
then
	echo "Minecraft port is open"
else
	echo "Minecraft port is not open"
fi

# Test Minecraft Service
if ssh -p 50001 Ubuntu-Minecraft-Server lsof -i tcp:25565 > /dev/null
then
	echo "Minecraft service is running"
else
	echo "Minecraft service is not running"
fi

# Ping Minecraft Server
if ping -c 2 -t 10 Ubuntu-Minecraft-Server > /dev/null
then
        echo "Ping Successful"
        #Check for open port
else
        echo "Not Successful"
fi
