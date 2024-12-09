#!/bin/bash
#
# pwrstatd-lowbatt.sh - This script is used by the PowerPanel software provided by the CyberPower vendor in conjunction with its UPS. The Nighthawks minecraft server is now connected to a CyberPower UPS to provide power when a power outage occurs.
# This script will be kicked off automatically by the PowerPanel software when the UPS battery is low (which means the UPS has been unplugged or there is a power outage).
# I wiped the entire default script that was here and replaced it with my own mailing system and discord notification system.
# Version: 1.1
#
# By: Brian Nichols

# Sending email
sendmail -t < /home/brian/email-templates/3504_battery_low.txt

# Sending discord message
/usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'UPS low battery identified. Shutting down the minecraft world and then powering off the minecraft server!'

# Shutdown minecraft world
/bin/bash /home/brian/repos/minecraft/minecraft-server-maintenance.sh "stop" "5" "Power Outage"
