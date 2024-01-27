#!/bin/bash
#
# minecraft-world-user-age.sh - This script will check for current players and document their play time.
# Version: 0.1
#
# By: Brian Nichols

# Variables:
current_users=''

# Check and acquire what users are logged in
screen -S minecraft -X stuff 'list''\015'
sleep 5
screen -S minecraft -X hardcopy "/home/brian/maintenance/minecraft-world-user-age.txt"

current_users=`tail -n2 /home/brian/maintenance/minecraft-world-user-age.txt | grep -v -e '^$'`

if [[ -z "$current_users" ]]; then
  echo "There are no users logged in"
else
  echo "These are the current_users: $current_users"
  IFS=","
  for i in $current_users
  do
    echo "User: $i"
  done
fi
