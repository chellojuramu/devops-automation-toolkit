#!/bin/bash
# ------------------------------------------------------------
# Script Name  : 14-install-packages-idempotent.sh
# Purpose      : Install packages only if not already installed
# OS           : Ubuntu
# Author       : Ramu Chelloju
# ------------------------------------------------------------

# -------------------- VARIABLES --------------------
USERID=$(id -u)

# Folder to store logs
LOGS_FOLDER="/var/log/shell-script"

# Script name without path (used for log file)
SCRIPT_NAME=$(basename "$0")

# Log file path
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# -------------------- COLORS --------------------
R="\e[31m"   # Red
G="\e[32m"   # Green
Y="\e[33m"   # Yellow
N="\e[0m"    # Reset / Normal

# -------------------- ROOT CHECK --------------------
# Package installation requires root access
if [ "$USERID" -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a "$LOGS_FILE"
    exit 1
fi

# -------------------- LOG DIRECTORY --------------------
# Create log directory if it does not exist
mkdir -p "$LOGS_FOLDER"

# Update package index once (best practice)
apt update -y &>> "$LOGS_FILE"

# -------------------- VALIDATION FUNCTION --------------------
# This function checks the exit status of the previous command
VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOGS_FILE"
    fi
}

# -------------------- PACKAGE INSTALL LOOP --------------------
# Usage example:
# sudo bash 14-install-packages-idempotent.sh nginx mysql-server nodejs

for package in "$@"
do
    # Check if package is already installed
    dpkg -s "$package" &>> "$LOGS_FILE"

    if [ $? -ne 0 ]; then
        # Package not installed
        echo -e "$package not installed, installing now" | tee -a "$LOGS_FILE"
        apt install -y "$package" &>> "$LOGS_FILE"
        VALIDATE $? "Installing $package"
    else
        # Package already installed
        echo -e "$package already installed ... $Y SKIPPING $N" | tee -a "$LOGS_FILE"
    fi
done
