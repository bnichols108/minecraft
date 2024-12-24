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

players_online = []

print("\nJoins and leaves:")

for line in lines:
    if "Player connected" in line:
        player = line.split(":")[4].replace(", xuid", "")[1:]
        time = f"{line.split(']')[0]}]".replace(" INFO", "")
        timestamp = re.sub(r'\:...]', ']', time)
        players_online.append(player)
        print(f"{timestamp} {Style.BRIGHT}{Fore.GREEN}join  + {player}{Style.RESET_ALL}")
        print("\nPlayers currently online:")
        for player in list(dict.fromkeys(players_online)):
            print(player)
    
    elif "Player disconnected" in line:
        player = line.split(":")[4].replace(", xuid", "")[1:]
        time = f"{line.split(']')[0]}]".replace(" INFO", "")
        players_online.pop(players_online.index(player))
        print(f"{time} {Style.BRIGHT}{Fore.RED}leave - {player}{Style.RESET_ALL}")
        print("\nPlayers currently online:")
        for player in list(dict.fromkeys(players_online)):
            print(player)
    
    elif "error" in line.lower() or "fail" in line.lower():
        output = line
        print(output)

    elif "LD_LIBRARY_PATH=. /home/brian/minecraft/running/bedrock_server" in line:
        # Minecraft world started. Setting players_online array to empty.
        players_online = []
        msg = "Minecraft world started. Setting players_online array to empty."
        print(msg)
        print("\nPlayers currently online:")
        for player in list(dict.fromkeys(players_online)):
            print(player)
        print("=======================================")
        print("\n")

print("\nPlayers online during the given timeframe:")

for player in list(dict.fromkeys(players_online)):
    print(player)

deinit()
