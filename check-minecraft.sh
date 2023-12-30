#!/bin/bash



#Check for network connectivity
#if ping -c 4 Ubuntu-Minecraft-Server > /dev/null
#then
#        echo "Ping Successful"
#        #Check for open port
#        if ssh -p 50001 Ubuntu-Minecraft-Server netstat -nap | grep 25565 > /dev/null
#        then
#                echo "Minecraft Server running"
#        else
#                echo "Minecraft Server not running"
#		mail -s "Minecraft Server Not Responding!" "##########@vtext.com" < /home/shadower/email-templates/minecraft_server_down.txt
#        fi
#else
#	echo "Not Successful"
#fi



#!/bin/bash
#
# ping-minecraft-server.sh - This script will ping my server,
#  and if it doesn't respond, send an email to myself
#

#ping -c 2 -t 1 192.168.0.101 > /dev/null 2> /dev/null

#if [ $? -eq 0 ]; then
#	echo "Server is up and running!"
		# Need to place a line here to run the next script and test if the minecraft service is running
#	else
	#       mail -s "Minecraft Server Not Responding!" "#######@gmail.com" < /home/shadower/email-templates/minecraft_server_down.txt
#	mail -s "Minecraft Server Not Responding!" "##########@vtext.com" < /home/shadower/email-templates/minecraft_server_down.txt
#	fi


if ssh -p 50001 Ubuntu-Minecraft-Server lsof -i tcp:25565 > /dev/null
then
	echo "Minecraft service is running"
else
	echo "Minecraft service is not running"
fi
