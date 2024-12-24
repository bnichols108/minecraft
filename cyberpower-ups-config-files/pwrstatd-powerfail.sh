#!/bin/bash
#
# pwrstatd-powerfail.sh - This script is used by the PowerPanel software provided by the CyberPower vendor in conjunction with its UPS. The Nighthawks minecraft server is now connected to a CyberPower UPS to provide power when a power outage occurs. 
# This script will be kicked off automatically by the PowerPanel software when a power outage occurs.
# I wiped the entire default script that was here and replaced it with my own mailing system and discord notification system. 
# Version: 1.1
#
# By: Brian Nichols

# Sending email
sendmail -t < /home/brian/email-templates/3504_power_failure.txt

# Sending discord message
/usr/bin/python3 /home/brian/repos/minecraft/discord-bot-for-minecraft-server.py 'Power is out at the house hosting the Minecraft server, but minecraft server still running!'
