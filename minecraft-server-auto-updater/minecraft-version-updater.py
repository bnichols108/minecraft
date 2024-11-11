# minecraft-version-updater.py - This script will be used to check for a new minecraft version and update the minecraft server version
# Version: 0.3
#
# By: Brian Nichols
# Original script by github user: ghwns9652
# https://github.com/ghwns9652/Minecraft-Bedrock-Server-Updater
#
# How to run this script:
# python3 minecraft-version-updater.py
# To run with the check only option:
# python3 minecraft-version-updater.py checkOnly


# Import modules
import requests
import logging
from bs4 import BeautifulSoup
import subprocess
import os
import sys
#import datetime (lower in the code)
#from datetime import datetime (lower in the code)

# Variables
minecraft_directory = '/home/brian/minecraft'
maintenance_directory = '/home/brian/maintenance'
minecraft_repo_directory = '/home/brian/repos/minecraft'
download_link_file = maintenance_directory+'/download_link.txt'
minecraft_versioning_file = maintenance_directory+'/minecraft-server-versioning.log'
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
os.system('echo "Read previous download link and set as a variable" | ts')
with open(download_link_file, 'r') as file:
    prev_download_link = file.read();

# Logic to check if there's a new version by comparing the download links (URLs). If there is a difference (ie newer version), continue. If versions are the same, exit.
if download_link != prev_download_link:
    # There is a new version available
    os.system('echo "There is a new Minecraft version available. Continuing." | ts')
else:
    # Already the latest version
    os.system('echo "Already the latest version. Nothing to update. Exiting." | ts')
    exit

# Check if minecraft service is running and exit if true
os.system('echo "Checking if minecraft service is currently running" | ts')
checkMinecraftService = subprocess.run(['pgrep', 'bedrock_server'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
if checkMinecraftService.returncode == 0:
    os.system('echo "Minecraft service running. Unable to run version upgrade. Exiting." | ts')
    exit()
os.system('echo "Minecraft service is not running. Good to continue with version upgrade." | ts')

# Download latest server version binary
os.system('echo "Downloading latest server version binary" | ts')
subprocess.run(['wget', '-U', 'Mozilla/5.0 (X11; CrOS x86_64 12871.102.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.141 Safari/537.36', '-P', maintenance_directory+'/', '-c', download_link])

# NEED TO ADD CHECK TO MAKE SURE WGET WORKED PROPERLY. If there is no file downloaded

# Migrate current server version to latest version (preserves server settings & world data)
os.system('echo "Migrating current server version to latest version. Kicking off minecraft-server-migrate.sh script" | ts')
subprocess.run(['bash', minecraft_repo_directory+'/minecraft-server-auto-updater/minecraft-server-migrate.sh', minecraft_directory])

# Make backup of download_link_file text file with timestamp (since used as a source of truth, just in case)
os.system('echo "Creating backup of download_link_file text file" | ts')
from datetime import datetime
timenow = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
subprocess.run(["cp", download_link_file, maintenance_directory+"/download_link-"+str(timenow)+".txt"])

# Write the latest download link to the download_link_file text file
os.system('echo "Write latest download link to the download_link_file text file" | ts')
with open(download_link_file, 'w') as file:
    file.write(download_link)

# Write latest version changes to the minecraft_versioning_file log
with open(minecraft_versioning_file, 'a') as file:
    import datetime
    timenow = "["+datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+"]"
    if prev_download_link == 'hello minecraft!':
        prev_version = 'unknown'
    else :
        prev_version = "v"+prev_download_link[prev_download_link.find('bedrock-server')+15:prev_download_link.find('.zip')]
    new_version = "v"+download_link[download_link.find('bedrock-server')+15:download_link.find('.zip')]
    msg = timenow+" minecraft server is updated from "+prev_version+" to "+new_version+"\n"
    file.write(msg)
