# minecraft-version-check-for-latest.py - This script will be used to check for the latest minecraft server version and return either True or False
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
download_link_file = maintenance_directory+'/download_link.txt'
URL = "https://www.minecraft.net/en-us/download/server/bedrock/"
BACKUP_URL = "https://raw.githubusercontent.com/ghwns9652/Minecraft-Bedrock-Server-Updater/main/backup_download_link.txt"
HEADERS = {"User-Agent": "Mozilla/5.0 (X11; CrOS x86_64 12871.102.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.141 Safari/537.36"}
newVersionAvailable = ""

# Attempt to grab latest Minecraft version download link
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
    with open(download_link_file, 'w') as file:
        file.write('hello minecraft!')

# Set previous download link as a variable
with open(download_link_file, 'r') as file:
    prev_download_link = file.read();

# Logic to check if there's a new version by comparing the download links (URLs).
if "error" in download_link.lower():
    # There was an error
    newVersionAvailable = "error"
elif download_link != prev_download_link:
    # There is a new version available
    newVersionAvailable = "true"
else:
    # Already the latest version
    newVersionAvailable = "false"

# Return value of newVersionAvailable variable
print(newVersionAvailable)
