#!/bin/bash
# ------------------------------------------------------------------
# Script Name : mongodb.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Configure MongoDB repository on RHEL
#   - Install MongoDB server
#   - Enable and start MongoDB service
#   - Allow remote connections (for Roboshop microservices)
#   - Log every step and fail safely on errors
#
# Usage:
#   sudo bash mongodb.sh
#
# Why sudo/root is required:
#   - Copy files into /etc
#   - Install packages using dnf
#   - Manage system services (systemctl)
# ------------------------------------------------------------------

# -------------------- SAFETY SETTINGS --------------------
# Exit immediately if any command fails
set -e

# -------------------- VARIABLES --------------------
USERID=$(id -u)   # id -u returns 0 for root, non-zero for normal user

LOGS_FOLDER="/var/log/shell-roboshop"   # Directory to store logs
SCRIPT_NAME=$(basename "$0")            # Extract only script name
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# Colors for readable output (only visual, no logic impact)
R="\e[31m"   # Red
G="\e[32m"   # Green
Y="\e[33m"   # Yellow
N="\e[0m"    # Reset

# -------------------- ROOT CHECK --------------------
# MongoDB installation and config require root access

if [ "$USERID" -ne 0 ]; then
    echo -e "$R ERROR: Please run this script with root access $N" | tee -a "$LOGS_FILE"
    exit 1
fi

# -------------------- LOG DIRECTORY --------------------
# Create log directory if it does not exist

mkdir -p "$LOGS_FOLDER"

# -------------------- VALIDATION FUNCTION --------------------
# This function checks the exit status of the previous command
# $1 -> exit code (0 = success, non-zero = failure)
# $2 -> message to print

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOGS_FILE"
    fi
}

# -------------------- STEP 1: ADD MONGODB REPOSITORY --------------------
# MongoDB is not available in default RHEL repos
# We copy the custom repo file so dnf knows where to download MongoDB

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOGS_FILE"
VALIDATE $? "Copying MongoDB repository file"

# -------------------- STEP 2: INSTALL MONGODB --------------------
# This installs MongoDB server and related tools

dnf install mongodb-org -y &>> "$LOGS_FILE"
VALIDATE $? "Installing MongoDB server"

# -------------------- STEP 3: ENABLE MONGODB SERVICE --------------------
# Enables MongoDB to start automatically on system reboot

systemctl enable mongod &>> "$LOGS_FILE"
VALIDATE $? "Enabling MongoDB service"

# -------------------- STEP 4: START MONGODB SERVICE --------------------
# Starts MongoDB immediately

systemctl start mongod &>> "$LOGS_FILE"
VALIDATE $? "Starting MongoDB service"

# -------------------- STEP 5: ALLOW REMOTE CONNECTIONS --------------------
# By default MongoDB binds only to 127.0.0.1 (localhost)
# Roboshop microservices run on different servers
# So we must allow MongoDB to listen on all network interfaces

# sed explanation:
# sed    -> stream editor (modify text in files)
# -i     -> edit file in-place (save changes)
# s      -> substitute
# 127.0.0.1 -> text to find
# 0.0.0.0   -> replacement text
# g      -> replace all occurrences

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> "$LOGS_FILE"
VALIDATE $? "Allowing remote MongoDB connections"

# -------------------- STEP 6: RESTART MONGODB --------------------
# Restart is required to apply configuration changes

systemctl restart mongod &>> "$LOGS_FILE"
VALIDATE $? "Restarting MongoDB service"

# -------------------- COMPLETION MESSAGE --------------------

echo -e "$G MongoDB installation and configuration completed successfully $N"
echo "Logs available at: $LOGS_FILE"
