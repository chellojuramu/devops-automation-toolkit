#!/bin/bash
# ------------------------------------------------------------------
# Script Name : catalogue.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Install and configure Catalogue microservice (NodeJS)
#   - Create application user (roboshop)
#   - Deploy application code
#   - Configure systemd service
#   - Load MongoDB initial data (idempotent)
#
# Usage:
#   sudo bash catalogue.sh
#
# Prerequisites:
#   - MongoDB service must be running
#   - DNS for MongoDB must be resolvable
# ------------------------------------------------------------------

# -------------------- SAFETY --------------------
# Exit immediately if any command fails
set -e

# -------------------- VARIABLES --------------------
USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

SCRIPT_DIR=$(pwd)                         # Directory from where script is executed
MONGODB_HOST="mongodb.servicewiz.in"      # MongoDB DNS name

# Colors (for readable output)
R="\e[31m"   # Red
G="\e[32m"   # Green
Y="\e[33m"   # Yellow
N="\e[0m"    # Reset

# -------------------- ROOT CHECK --------------------
# Package installation, system user creation and service setup need root access

if [ "$USERID" -ne 0 ]; then
    echo -e "$R ERROR: Please run this script with root access $N" | tee -a "$LOGS_FILE"
    exit 1
fi

# -------------------- LOG DIRECTORY --------------------
# Create log directory if it does not exist
mkdir -p "$LOGS_FOLDER"

# -------------------- VALIDATION FUNCTION --------------------
# Checks exit status of previous command
# $1 -> exit code
# $2 -> message to print

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOGS_FILE"
    fi
}

# -------------------- NODEJS SETUP --------------------
# Disable default NodeJS module (older versions)
dnf module disable nodejs -y &>>"$LOGS_FILE"
VALIDATE $? "Disabling default NodeJS module"

# Enable NodeJS version 20
dnf module enable nodejs:20 -y &>>"$LOGS_FILE"
VALIDATE $? "Enabling NodeJS 20 module"

# Install NodeJS
dnf install nodejs -y &>>"$LOGS_FILE"
VALIDATE $? "Installing NodeJS"

# -------------------- APPLICATION USER --------------------
# Check if roboshop user exists, create if not

id roboshop &>>"$LOGS_FILE"
if [ $? -ne 0 ]; then
    useradd \
        --system \
        --home /app \
        --shell /sbin/nologin \
        --comment "roboshop system user" \
        roboshop &>>"$LOGS_FILE"
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "Roboshop user already exists ... $Y SKIPPING $N" | tee -a "$LOGS_FILE"
fi

# -------------------- APPLICATION DIRECTORY --------------------
# Create /app directory for application code
mkdir -p /app
VALIDATE $? "Creating /app directory"

# -------------------- DOWNLOAD APPLICATION CODE --------------------
curl -o /tmp/catalogue.zip \
    https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip \
    &>>"$LOGS_FILE"
VALIDATE $? "Downloading catalogue application code"

# Move into /app directory
cd /app
VALIDATE $? "Moving to /app directory"

# Clean existing code (safe redeployment)
rm -rf /app/*
VALIDATE $? "Removing existing application code"

# Extract application
unzip /tmp/catalogue.zip &>>"$LOGS_FILE"
VALIDATE $? "Extracting catalogue code"

# -------------------- INSTALL DEPENDENCIES --------------------
# Install NodeJS dependencies defined in package.json
npm install &>>"$LOGS_FILE"
VALIDATE $? "Installing NodeJS dependencies"

# -------------------- SYSTEMD SERVICE SETUP --------------------
# Copy service file to systemd directory
cp "$SCRIPT_DIR/catalogue.service" /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue systemd service file"

# Reload systemd to recognize new service
systemctl daemon-reload &>>"$LOGS_FILE"

# Enable and start catalogue service
systemctl enable catalogue &>>"$LOGS_FILE"
systemctl start catalogue &>>"$LOGS_FILE"
VALIDATE $? "Starting and enabling catalogue service"

# -------------------- MONGODB CLIENT --------------------
# Install MongoDB shell client (mongosh)
cp "$SCRIPT_DIR/mongo.repo" /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>"$LOGS_FILE"
VALIDATE $? "Installing MongoDB client (mongosh)"

# -------------------- LOAD DATABASE DATA --------------------
# Check if catalogue database already exists
INDEX=$(mongosh --host "$MONGODB_HOST" --quiet \
    --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ "$INDEX" -lt 0 ]; then
    mongosh --host "$MONGODB_HOST" </app/db/master-data.js &>>"$LOGS_FILE"
    VALIDATE $? "Loading catalogue product data into MongoDB"
else
    echo -e "Catalogue data already exists ... $Y SKIPPING $N" | tee -a "$LOGS_FILE"
fi

# -------------------- RESTART SERVICE --------------------
# Restart catalogue service to ensure DB connectivity
systemctl restart catalogue &>>"$LOGS_FILE"
VALIDATE $? "Restarting catalogue service"

# -------------------- COMPLETION --------------------
echo -e "$G Catalogue service deployment completed successfully $N"
echo "Logs available at: $LOGS_FILE"
