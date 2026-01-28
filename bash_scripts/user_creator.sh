#!/bin/bash
USERNAME=$1
echo "the username requested is: $USERNAME"
if [ -z "$USERNAME" ]; then
    echo "Error: You forgot to provide a username!"
    echo "Usage: ./user_creator.sh <username>"
    exit 1
fi
PASSWORD=$(date +%s | md5sum | head -c 8)
echo "Creating user $USERNAME..."
sudo useradd -m $USERNAME
echo "$USERNAME:$PASSWORD" | sudo chpasswd
echo "$USERNAME,$PASSWORD" >> user_creds.csv
echo "Success! User $USERNAME created."
echo "Credentials saved locally to 'user_creds.csv'"