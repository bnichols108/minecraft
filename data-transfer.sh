#!/bin/bash

#data-transfer.sh - This script is going to help automate copying data from one server to another
#
#


#Need to find out what needs to be copied

user=`whoami`

echo "Welcome to the data transfer script!"
echo "Which server are you transferring to? You can type the IP or hostname!"
echo "Server:" 
read server

echo "1: Transfer a single file"
echo "2: Transfer multiple files"
echo "3: Transfer a directory"
echo "4: Quit (or just type quit)"
echo "Choose an option from above: "
read answer

if [ "$server" == "BRNUBSR1" ] || [ "$server" == "192.168.0.101" ] ; then
	port=19389

elif [ "$server" == "BRNUBSR2" ] || [ "$server" == "192.168.0.102" ] ; then
	port=19489
else
	echo "Not sure of that server"
fi

if [ "$answer" == "1" ] ; then
	echo "Name of the file: "
	read filename
	echo "Where to place the file: "
	read location
	scp -P $port $filename $user@$server:$location
fi

