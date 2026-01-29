#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# Root access check
if [ "$USERID" -ne 0 ]; then
    echo "Please run this script with root user access" | tee -a "$LOGS_FILE"
    exit 1
fi

# Create logs directory
mkdir -p "$LOGS_FOLDER"

# Update package index once
apt update -y &>> "$LOGS_FILE"

# Validation function
VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo "$2 ... FAILURE" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo "$2 ... SUCCESS" | tee -a "$LOGS_FILE"
    fi
}

# Loop through all arguments
for package in "$@"   # example: sudo bash script.sh nginx mysql-server nodejs
do
    apt install -y "$package" &>> "$LOGS_FILE"
    VALIDATE $? "Installing $package"
done
