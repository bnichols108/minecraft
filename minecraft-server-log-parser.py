#!/bin/bash
#
# minecraft-server-log-parser.py - This script will be used to parse the Minecraft service screen session log output and direct that data to other files
# Version: 0.1
#
# By: Brian Nichols
# Original script by github user: Iapetus-11
# https://github.com/Iapetus-11/MC-Bedrock-Server-Log-Parser/blob/master/parser.py

import time
from colorama import *
import re
import datetime

players_online = []

def follow_log(log_file):
    """Tails a log file and yields new lines."""
    with open(log_file, 'r') as f:
        f.seek(0, 2)  # Go to the end of the file
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.1)  # Sleep briefly if no new lines
                continue
            yield line

def parse_log_line(line):
    if "Player connected" in line:
        player = line.split(":")[4].replace(", xuid", "")[1:]
        time = f"{line.split(']')[0]}]".replace(" INFO", "")
        timestamp = re.sub(r'\:...]', ']', time)
        players_online.append(player)
        
        print(timestamp+",join,"+player)
        #g.write(timestamp+",join,"+player)
        
        print("\nPlayers currently online:")
        for player in list(dict.fromkeys(players_online)):
            print(player)

    elif "Player disconnected" in line:
        player = line.split(":")[4].replace(", xuid", "")[1:]
        time = f"{line.split(']')[0]}]".replace(" INFO", "")
        timestamp = re.sub(r'\:...]', ']', time)
        players_online.pop(players_online.index(player))
        
        print(timestamp+",quit,"+player)
        print("\nPlayers currently online:")
        for player in list(dict.fromkeys(players_online)):
            print(player)
    
    elif "error" in line.lower() or "fail" in line.lower():
        output = line
        print(output)

    elif "Server stop requested" in line:
        # Minecraft world stopped. Sending current users_playtime then setting players_online array to empty
        timestamp = "["+datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+"]"
        for player in list(dict.fromkeys(players_online)):
            print(timestamp+",quit,"+player)
        players_online.clear()

if __name__ == '__main__':
    log_file_path = '/home/brian/maintenance/minecraft-server-live-log.log'
    user_playtime = '/home/brian/maintenance/minecraft-user-playtime.txt'
    current_users = '/home/brian/maintenance/minecraft-world-current-users.txt'

    g=open(user_playtime, 'w')
    #    f.write('\n')
    for line in follow_log(log_file_path):
        parse_log_line(line)
    g.close()
