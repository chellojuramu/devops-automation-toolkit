#!/bin/bash
# ---------------------------------------------------------
# Script Name : user_creator.sh
# Author      : Ramu Chelloju
# Purpose     : Create a Linux user safely with auto-generated password
# Usage       : ./user_creator.sh <username>
# ---------------------------------------------------------

# $1 means: first argument passed while running the script
# Example: ./user_creator.sh ramu
USERNAME=$1

echo "The username requested is: $USERNAME"

# ---------------------------------------------------------
# 1️⃣ Validate input (very important for safe automation)
# -z checks if the variable is EMPTY
# ---------------------------------------------------------
if [ -z "$USERNAME" ]; then
    echo "Error: You forgot to provide a username!"
    echo "Usage: ./user_creator.sh <username>"
    exit 1   # Exit with error
fi

# ---------------------------------------------------------
# 2️⃣ Check if user already exists
# id -u <username> returns UID if user exists
# &>/dev/null hides output (clean terminal)
# ---------------------------------------------------------
if id -u "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists! No changes made."
    exit 0   # Exit gracefully (idempotent behavior)
fi

# ---------------------------------------------------------
# 3️⃣ Generate a random password
# date +%s        -> current timestamp
# md5sum          -> convert to hash
# head -c 8       -> take first 8 characters
# ---------------------------------------------------------
PASSWORD=$(date +%s | md5sum | head -c 8)

# ---------------------------------------------------------
# 4️⃣ Create the user
# -m : create home directory
# -s : assign login shell
# ---------------------------------------------------------
echo "Creating user $USERNAME..."
sudo useradd -m -s /bin/bash "$USERNAME"

# ---------------------------------------------------------
# 5️⃣ Set password for the user
# chpasswd reads "username:password" format from stdin
# ---------------------------------------------------------
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# ---------------------------------------------------------
# 6️⃣ Store credentials (for admin reference)
# Appends username and password to CSV file
# ---------------------------------------------------------
echo "$USERNAME,$PASSWORD" >> user_creds.csv

# ---------------------------------------------------------
# 7️⃣ Final success message
# ---------------------------------------------------------
echo "Success! User $USERNAME created."
echo "User $USERNAME created with Bash shell."
