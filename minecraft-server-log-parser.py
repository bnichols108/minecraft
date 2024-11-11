#!/bin/bash
#
# minecraft-server-maintenance.sh - This script will be used to run other scripts to perform maintenance on the Nighthawks minecraft server
# Version: 0.1
#
# By: Brian Nichols
# Original script by github user: Iapetus-11
# https://github.com/Iapetus-11/MC-Bedrock-Server-Log-Parser/blob/master/parser.py

import time
from colorama import *

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
    """Parses a log line according to your specific format."""
    # Example: Split by space and extract fields
    #fields = line.split()
    #timestamp = fields[0]
    #event_type = fields[1]
    # ... extract other fields as needed
    #players_online = []
    if "Player connected" in line:
        player = line.split(":")[4].replace(", xuid", "")[1:]
        time = f"{line.split(']')[0]}]".replace(" INFO", "")
        players_online.append(player)
        print(f"{time} {Style.BRIGHT}{Fore.GREEN}join  + {player}{Style.RESET_ALL}")
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

if __name__ == '__main__':
    log_file_path = '/home/brian/maintenance/minecraft-server-live-log.log'

    for line in follow_log(log_file_path):
        parse_log_line(line)
        #print(timestamp, event_type, fields)  # Or do something else with the parsed data
