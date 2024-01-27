#!/bin/bash
#
# minecraft-world-user-age.sh - This script will check for current players and document their play time.
# Version: 0.1
#
# By: Brian Nichols

# Variables:
current_users=''
count=0

while [ $count -le 4 ]
do
  screen -S minecraft -X stuff 'list''\015'
  sleep 3
  screen -S minecraft -X hardcopy "/home/brian/maintenance/minecraft-world-user-age.txt"

  current_users=`tail -n3 /home/brian/maintenance/minecraft-world-user-age.txt`
  echo "$current_users"
  echo "Current users in while loop is:" "$current_users"
  echo "========="
  if [[ `echo "$current_users" | grep "players online"` ]]; then
    echo "Received the list of users. Exiting while loop."
    echo "Count currently is: $count"
    break
  fi 
  echo "Count currently is: $count"
  count=$((count+1))
  echo "Count currently is: $count"
done

if [[ $count -eq 5 ]]; then
  echo "we've ran 5 times, got no players online, exiting"
  exit 0
fi

echo "Current users before attempting to remove the first line is: $current_users"
echo ""
current_users=`echo "$current_users" | grep -v "players online"`

echo "Current users after attempting to remove the first line is: $current_users"
echo ""

if [[ -z "$current_users" ]]; then
  echo "There are no users logged in"
  exit 0
else
  echo "These are the current_users: $current_users"
  IFS=","
  for username in $current_users
  do
    # This echo statement includes the xargs to remove the following usernames that have leading whitspaces.
    echo "Username: "`echo "$username" | xargs`
  done
fi
