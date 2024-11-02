# minecraft-version-updater.py - This script will be used to update the minecraft server version
# Version: 0.3
#
# By: Brian Nichols
# Original script by github user: ghwns9652
# https://github.com/ghwns9652/Minecraft-Bedrock-Server-Updater
#
# How to run this script:
# python3 minecraft-version-updater.py

# Import modules
import requests
import logging
from bs4 import BeautifulSoup
import subprocess
import os
import sys
import datetime

# Variables
minecraft_directory = '/home/brian/minecraft'
maintenance_directory = '/home/brian/maintenance'
minecraft_repo_directory = '/home/brian/repos/minecraft'
download_link_file = maintenance_directory+'/download_link.txt'
minecraft_versioning_file = maintenance_directory+'/minecraft-server-versioning.log'

# Download latest server version binary
os.system('echo "Downloading latest server version binary" | ts')
subprocess.run(['wget', '-P', maintenance_directory+'/', '-c', download_link])

# Check if minecraft service is running and exit if true

# Migrate current server version to latest version (preserves server settings & world data)
os.system('echo "Migrating current server version to latest version. Kicking off minecraft-server-migrate.sh script" | ts')
subprocess.run(['bash', minecraft_repo_directory+'/minecraft-server-auto-updater/minecraft-server-migrate.sh', minecraft_directory])

# Make backup of download_link_file text file with timestamp (since used as a source of truth, just in case)


# Set previous download link as a variable
os.system('echo "Read previous download link and set as a variable" | ts')
with open(download_link_file, 'r') as file:
    prev_download_link = file.read();

# Write the latest download link to the download_link_file text file
os.system('echo "Write latest download link to the download_link_file text file" | ts')
with open(download_link_file, 'w') as file:
    file.write(download_link)

# Write latest version changes to the minecraft_versioning_file log
with open(minecraft_versioning_file, 'a') as file:
    timenow = "["+datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+"]"
    if prev_download_link == 'hello minecraft!':
        prev_version = 'unknown'
    else :
        prev_version = "v"+prev_download_link[prev_download_link.find('bedrock')+15:prev_download_link.find('.zip')]
    new_version = "v"+download_link[download_link.find('bedrock')+15:download_link.find('.zip')]
    msg = timenow+" minecraft server is updated "+"("+prev_version+" -> "+new_version+")\n"
    print(msg)
    file.write(msg)

