#!/bin/bash
# -------------------------------------------------
# Script Name : install_packages_with_logging.sh
# Author      : Ramu Chelloju
# Platform    : Ubuntu
# Purpose     : Install packages with logging & validation
# -------------------------------------------------

# Get the User ID of the person running the script
# Root user always has UID = 0
USERID=$(id -u)

# Folder where logs will be stored
LOGS_FOLDER="/var/log/shell-script"

# basename extracts only the script name (without path)
# Example: /home/ubuntu/install.sh -> install.sh
SCRIPT_NAME=$(basename "$0")

# Full path of the log file
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# -------------------------------------------------
# Root user check
# -------------------------------------------------
# Package installation requires root privileges
if [ "$USERID" -ne 0 ]; then
    echo "Please run this script with root user access" | tee -a "$LOGS_FILE"
    exit 1
fi

# -------------------------------------------------
# Create logs directory if it doesn't exist
# -p ensures no error if directory already exists
# -------------------------------------------------
mkdir -p "$LOGS_FOLDER"

# -------------------------------------------------
# Update package index once
# &>> redirects both stdout and stderr to log file
# -------------------------------------------------
apt update -y &>> "$LOGS_FILE"

# -------------------------------------------------
# Function: VALIDATE
# Arguments:
#   $1 -> exit status of previous command
#   $2 -> message to display
# -------------------------------------------------
VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo "$2 ... FAILURE" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo "$2 ... SUCCESS" | tee -a "$LOGS_FILE"
    fi
}

# -------------------------------------------------
# Install Nginx
# -------------------------------------------------
apt install -y nginx &>> "$LOGS_FILE"
VALIDATE $? "Installing Nginx"

# -------------------------------------------------
# Install MySQL Server
# -------------------------------------------------
apt install -y mysql-server &>> "$LOGS_FILE"
VALIDATE $? "Installing MySQL"

# -------------------------------------------------
# Install NodeJS
# -------------------------------------------------
apt install -y nodejs &>> "$LOGS_FILE"
VALIDATE $? "Installing NodeJS"
