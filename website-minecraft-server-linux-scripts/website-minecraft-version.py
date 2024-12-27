#!/bin/bash
#
# minecraft-server-log-parser.py - This script will be used to parse the Minecraft service screen session log output and direct that data to other files
# Version: 0.1
#
# By: Brian Nichols
# Original script by github user: Iapetus-11
# https://github.com/Iapetus-11/MC-Bedrock-Server-Log-Parser/blob/master/parser.py

# file name of the log file
file_name = "/home/brian/maintenance/minecraft-server-live-log.log"

from colorama import *
import re
init()

with open(file_name, "r") as f:
    lines = f.readlines()

for line in reversed(lines):
    if "INFO] Version: " in line:
        currentVersion = line.split(":")[4].replace(" ", "").strip()
        print(currentVersion)
        break

f = open("/home/brian/maintenance/website-minecraft-status-files/minecraft-service-version.txt", "w")
f.write("v"+currentVersion)
f.close()

deinit()
