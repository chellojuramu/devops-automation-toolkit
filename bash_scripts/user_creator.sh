#!/bin/bash
USERNAME=$1
echo "the username requested is: $USERNAME"
if [ -z "$USERNAME" ]; then
    echo "Error: You forgot to provide a username!"
    echo "Usage: ./user_creator.sh <username>"
    exit 1
fi

if id -u "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists! No changes made."
    exit 0
fi

PASSWORD=$(date +%s | md5sum | head -c 8)
echo "Creating user $USERNAME..."
sudo useradd -m -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | sudo chpasswd
echo "$USERNAME,$PASSWORD" >> user_creds.csv
echo "Success! User $USERNAME created."
echo "Success! User $USERNAME created with Bash shell."
