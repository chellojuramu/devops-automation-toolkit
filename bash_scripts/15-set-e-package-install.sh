#!/bin/bash
# ------------------------------------------------------------
# Script Name : 15-set-e-package-install.sh
# Purpose     : Install packages only if not already installed
# OS          : Ubuntu
# Concept     : set -e (automatic failure handling)
# ------------------------------------------------------------

# Exit immediately if any command fails
set -e

# -------------------- VARIABLES --------------------
USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# -------------------- COLORS --------------------
R="\e[31m"   # Red
G="\e[32m"   # Green
Y="\e[33m"   # Yellow
N="\e[0m"    # Reset

# -------------------- ROOT CHECK --------------------
# Package installation requires root access
if [ "$USERID" -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a "$LOGS_FILE"
    exit 1
fi

# -------------------- LOG DIRECTORY --------------------
# Create log directory if it does not exist
mkdir -p "$LOGS_FOLDER"

# -------------------- UPDATE PACKAGE INDEX --------------------
# Run once (best practice)
apt update -y &>> "$LOGS_FILE"

# -------------------- PACKAGE INSTALL LOOP --------------------
# Usage example:
# sudo bash 15-set-e-package-install.sh nginx mysql-server nodejs

for package in "$@"
do
    # Check if the package is already installed
    dpkg -s "$package" &>> "$LOGS_FILE"

    if [ $? -ne 0 ]; then
        # Package not installed → install it
        echo -e "$package not installed, installing now" | tee -a "$LOGS_FILE"
        apt install -y "$package" &>> "$LOGS_FILE"
        echo -e "Installing $package ... $G SUCCESS $N" | tee -a "$LOGS_FILE"
    else
        # Package already installed → skip
        echo -e "$package already installed ... $Y SKIPPING $N" | tee -a "$LOGS_FILE"
    fi
done
