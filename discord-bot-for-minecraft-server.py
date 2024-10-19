# discord-bot-for-minecraft-server.py - This script will be used to send messages to the NightHawks discord server.
# Version: 0.1
#
# By: Brian Nichols
#
# Run this script via the following:
# python3 discord-bot-for-minecraft-server.py <message>

# NOTE: Make sure to have two environment variables set before running this - DISCORD_TOKEN and DISCORD_CHANNEL

import discord
import sys
import os

# Replace with your bot token
TOKEN = str(os.environ.get('DISCORD_TOKEN'))

# Create a Discord client
client = discord.Client(intents=discord.Intents.default())

@client.event
async def on_ready():
    print(f'Logged in as {client.user}')

    # Replace with your channel ID
    channel_id = int(os.environ.get('DISCORD_CHANNEL'))

    channel = client.get_channel(channel_id)
    if channel:
        await channel.send(sys.argv[1])
        await client.close()
    else:
        print('Channel not found.')

client.run(TOKEN)
