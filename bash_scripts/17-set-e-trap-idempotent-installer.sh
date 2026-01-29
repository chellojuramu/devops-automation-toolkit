#!/bin/bash
# ------------------------------------------------------------------
# Script Name : 17-set-e-trap-idempotent-installer.sh
# Author      : Ramu Chelloju
# Purpose     : Install packages safely on Ubuntu using fail-fast
#               mechanism (set -e) with error diagnostics (trap ERR)
# OS          : Ubuntu
#
# Usage:
#   sudo bash 17-set-e-trap-idempotent-installer.sh nginx mysql-server nodejs
#
# Key Concepts Used:
#   - set -e        → Exit immediately if any command fails
#   - trap ERR     → Capture error details (line number & command)
#   - Idempotency  → Install only if package is not already installed
#   - Logging      → Store logs for troubleshooting
# ------------------------------------------------------------------

# -------------------- FAIL FAST --------------------
# Exit the script immediately if any command returns a non-zero status
set -e

# -------------------- ERROR HANDLING --------------------
# This trap runs automatically when any command fails
# $LINENO        → Line number where the error occurred
# $BASH_COMMAND  → The exact command that caused the error
trap 'echo "ERROR occurred at line $LINENO | Command: $BASH_COMMAND"' ERR

# -------------------- VARIABLES --------------------
# Get the user ID of the person running the script
USERID=$(id -u)

# Directory where logs will be stored
LOGS_FOLDER="/var/log/shell-script"

# Extract only the script name (without full path)
SCRIPT_NAME=$(basename "$0")

# Full path of the log file
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# -------------------- COLOR CODES --------------------
# Used for better readability in terminal output
R="\e[31m"   # Red    → Errors
G="\e[32m"   # Green  → Success
Y="\e[33m"   # Yellow → Skipped / Warnings
N="\e[0m"    # Reset  → Normal text

# -------------------- ROOT USER CHECK --------------------
# Package installation requires root access
if [ "$USERID" -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a "$LOGS_FILE"
    exit 1
fi

# -------------------- LOG DIRECTORY --------------------
# Create log directory if it does not exist
# -p avoids error if directory already exists
mkdir -p "$LOGS_FOLDER"

# -------------------- PACKAGE INDEX UPDATE --------------------
# Update package repository once (best practice)
apt update -y &>> "$LOGS_FILE"

# -------------------- PACKAGE INSTALL LOOP --------------------
# $@ represents all arguments passed to the script
# Example:
#   sudo bash script.sh nginx mysql-server nodejs

for package in "$@"
do
    # Check whether the package is already installed
    # dpkg -s returns:
    #   0 → package is installed
    #   non-zero → package is NOT installed
    dpkg -s "$package" &>> "$LOGS_FILE"

    if [ $? -ne 0 ]; then
        # Package is not installed → install it
        echo -e "$package not installed, installing now" | tee -a "$LOGS_FILE"
        apt install -y "$package" &>> "$LOGS_FILE"

        # If apt install fails, set -e will stop the script
        echo -e "Installing $package ... $G SUCCESS $N" | tee -a "$LOGS_FILE"
    else
        # Package already installed → skip installation
        echo -e "$package already installed ... $Y SKIPPING $N" | tee -a "$LOGS_FILE"
    fi
done
