#!/bin/bash
# ------------------------------------------------------------------
# Script Name : cart.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Install and configure cart for RoboShop
#   - Configure cart to backend services
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
echo "Configuring RoboShop cart..."

# -------------------- NodejS INSTALLATION --------------------
dnf module disable nodejs -y &>>"$LOGS_FILE"
VALIDATE $? "Disabling default Nodejs module"

dnf module enable nodejs:20 -y &>>"$LOGS_FILE"
VALIDATE $? "Enabling nodejs 20 module"

dnf install nodejs -y &>>"$LOGS_FILE"
VALIDATE $? "Installing nodejs"

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
curl -o /tmp/cart.zip \
    https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip \
    &>>"$LOGS_FILE"
VALIDATE $? "Downloading cart application code"

# Move into /app directory
cd /app
VALIDATE $? "Moving to /app directory"

# Clean existing code (safe redeployment)
rm -rf /app/*
VALIDATE $? "Removing existing application code"

# Extract application
unzip /tmp/cart.zip &>>"$LOGS_FILE"

# -------------------- INSTALL DEPENDENCIES --------------------
# Install NodeJS dependencies defined in package.json
npm install &>>"$LOGS_FILE"
VALIDATE $? "Installing NodeJS dependencies"

# -------------------- SYSTEMD SERVICE SETUP --------------------
# Copy service file to systemd directory
cp "$SCRIPT_DIR/cart.service" /etc/systemd/system/cart.service
VALIDATE $? "Copying cart systemd service file"

# Reload systemd to recognize new service
systemctl daemon-reload &>>"$LOGS_FILE"

# Enable and start cart service
systemctl enable cart &>>"$LOGS_FILE"
systemctl start cart &>>"$LOGS_FILE"
VALIDATE $? "Starting and enabling cart service"