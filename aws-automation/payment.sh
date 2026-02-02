#!/bin/bash
# ------------------------------------------------------------------
# Script Name : payment.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Install and configure payment for RoboShop
#   - Configure payment to backend services
#
# OS          : RHEL / Amazon Linux
# ------------------------------------------------------------------

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$(pwd)                         # Directory from where script is executed

# -------------------- COLORS --------------------
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# -------------------- ROOT CHECK --------------------
if [ "$USERID" -ne 0 ]; then
    echo -e "$R Please run this script with root access $N" | tee -a "$LOGS_FILE"
    exit 1
fi

mkdir -p "$LOGS_FOLDER"

# -------------------- VALIDATION FUNCTION --------------------
VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOGS_FILE"
    fi
}
echo "Configuring RoboShop Payment..."

# -------------------- Python 3 INSTALLATION --------------------
dnf install python3 gcc python3-devel -y &>>"$LOGS_FILE"
VALIDATE $? "Installing Python 3"

# -------------------- APPLICATION USER --------------------
# Check if roboshop user exists, create if not

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

# -------------------- APPLICATION DIRECTORY --------------------
# Create /app directory for application code
mkdir -p /app
VALIDATE $? "Creating /app directory"
# -------------------- DOWNLOAD APPLICATION CODE --------------------
curl -o /tmp/payment.zip \
    https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip \
    &>>"$LOGS_FILE"
VALIDATE $? "Downloading payment application code"

# Move into /app directory
cd /app
VALIDATE $? "Moving to /app directory"

# Clean existing code (safe redeployment)
rm -rf /app/*
VALIDATE $? "Removing existing application code"

# Extract application
unzip /tmp/payment.zip &>>"$LOGS_FILE"


# -------------------- INSTALL DEPENDENCIES --------------------
# Install NodeJS dependencies defined in package.json
pip3 install -r requirements.txt &>>"$LOGS_FILE"
VALIDATE $? "Installing python dependencies"

# -------------------- SYSTEMD SERVICE SETUP --------------------
# Copy the service file to systemd directory
cp "$SCRIPT_DIR/payment.service" /etc/systemd/system/payment.service
VALIDATE $? "Copying payment systemd service file"

# Reload systemd to recognize the new service
systemctl daemon-reload &>>"$LOGS_FILE"

# Enable and start the payment service
systemctl enable payment &>>"$LOGS_FILE"
systemctl start payment &>>"$LOGS_FILE"
VALIDATE $? "Starting and enabling payment service"