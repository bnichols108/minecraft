# minecraft-version-check-for-latest.py - This script will be used to check for the latest minecraft server version
# Version: 0.1
#
# By: Brian Nichols
# Original script by github user: ghwns9652
# https://github.com/ghwns9652/Minecraft-Bedrock-Server-Updater
#
# How to run this script:
# python3 minecraft-version-check-for-latest.py

# Import modules
import requests
import logging
from bs4 import BeautifulSoup
import subprocess
import os
import sys
import datetime

# Variables
maintenance_directory = '/home/brian/maintenance'
minecraft_repo_directory = '/home/brian/repos/minecraft'
download_link_file = maintenance_directory+'/download_link.txt'
URL = "https://www.minecraft.net/en-us/download/server/bedrock/"
BACKUP_URL = "https://raw.githubusercontent.com/ghwns9652/Minecraft-Bedrock-Server-Updater/main/backup_download_link.txt"
HEADERS = {"User-Agent": "Mozilla/5.0 (X11; CrOS x86_64 12871.102.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.141 Safari/537.36"}

# Attempt to grab latest Minecraft version download link
os.system('echo "Attempting to grab the latest Minecraft version download link" | ts')
try:
    page = requests.get(URL, headers=HEADERS, timeout=5)

    soup = BeautifulSoup(page.content, "html.parser")

    a_tag_res = []
    for a_tags in soup.findAll('a', attrs={"aria-label":"Download Minecraft Dedicated Server software for Ubuntu (Linux)"}):
      a_tag_res.append(a_tags['href'])

    download_link=a_tag_res[0]

except requests.exceptions.Timeout:
    logging.error("timeout raised, recovering")
    page = requests.get(BACKUP_URL, headers=HEADERS, timeout=5)

    download_link=page.text

# Check if download_link_file is created. If not, create it 
if not os.path.isfile(download_link_file):
    os.system('echo "No download_link_file text file found. Creating one." | ts')
    with open(download_link_file, 'w') as file:
        file.write('hello minecraft!')

# Set previous download link as a variable
with open(download_link_file, 'r') as file:
    prev_download_link = file.read();

# Logic to check if there's a new version by comparing the download links (URLs). If there is a difference (ie newer version) then schedule 
if download_link != prev_download_link:
    # There is a new version available
    os.system('echo "There is a new Minecraft version available" | ts')
    os.system('echo "Sending message to Nighthawks discord" | ts')
    subprocess.run(['python3', minecraft_repo_directory+'/discord-bot-for-minecraft-server.py','There is a new minecraft version available'])
else:
    # Already the latest version
    os.system('echo "Already the latest version. Nothing to update. Closing." | ts')
