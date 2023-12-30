#!/bin/bash
#
# check-external-ip.sh - This script will email my external IP to my email address if it changes
#
# By: Brian Nichols

IP_FILE=$(cat /home/shadower/scripts/external-ip/ipaddress.txt)
CURRENT_IP=$(echo `curl -s -4 http://icanhazip.com/`)
DOWNTIME=$(cat /home/shadower/scripts/external-ip/downtime.txt)
DATE=`date +%Y-%m-%d.%H-%M-%S`

if [ "$CURRENT_IP" != "$IP_FILE" ] && [ "$CURRENT_IP" != "" ]; then
	sed '5r /home/shadower/scripts/external-ip/ipaddress.txt' '/home/shadower/notifications/ip-change.txt' > /home/shadower/scripts/external-ip/temp-ip-change.txt
	echo $CURRENT_IP > /home/shadower/scripts/external-ip/ipaddress.txt
	sed -i '8r /home/shadower/scripts/external-ip/ipaddress.txt' '/home/shadower/scripts/external-ip/temp-ip-change.txt'
	mail -s "Apartment External IP Changed!" "Shadower108@gmail.com" < /home/shadower/scripts/external-ip/temp-ip-change.txt
	rm /home/shadower/scripts/external-ip/temp-ip-change.txt
fi

if [ "$CURRENT_IP" == "" ]; then
	if [ "$DOWNTIME" -eq 0 ]; then
		echo 1 > /home/shadower/scripts/external-ip/downtime.txt

	elif [ "$DOWNTIME" -ge 1 ]; then
		((DOWNTIME++))
		echo $DOWNTIME > /home/shadower/scripts/external-ip/downtime.txt
	fi
fi

if [ "$CURRENT_IP" != "" ]; then
	if [ "$DOWNTIME" -ge 1 ]; then
		cat /home/shadower/scripts/external-ip/downtime.txt > "/home/shadower/scripts/external-ip/downtime-$DATE.txt"
		echo 0 > /home/shadower/scripts/external-ip/downtime.txt
	fi
fi
