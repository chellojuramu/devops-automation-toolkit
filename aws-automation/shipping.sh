#!/bin/bash
# ------------------------------------------------------------------
# Script Name : shipping.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Install and configure shipping for RoboShop
#   - Configure shipping to backend services
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
echo "Configuring RoboShop shipping..."

# -------------------- MAVEN INSTALLATION --------------------
dnf install maven -y &>>"$LOGS_FILE"
VALIDATE $? "Installing Maven"

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
curl -o /tmp/shipping.zip \
    https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip \
    &>>"$LOGS_FILE"
VALIDATE $? "Downloading shipping application code"

# Move into /app directory
cd /app
VALIDATE $? "Moving to /app directory"

# Clean existing code (safe redeployment)
rm -rf /app/*
VALIDATE $? "Removing existing application code"

# Extract application
unzip /tmp/shipping.zip &>>"$LOGS_FILE"

# Build the package using Maven
mvn clean package &>>"$LOGS_FILE"
VALIDATE $? "Building shipping application with Maven"

# Rename the artifact to a standard name for the service file
mv target/shipping-1.0.jar shipping.jar &>>"$LOGS_FILE"
VALIDATE $? "Renaming shipping artifact"

# -------------------- SYSTEMD SERVICE SETUP --------------------
cp "$SCRIPT_DIR/shipping.service" /etc/systemd/system/shipping.service
VALIDATE $? "Copying shipping systemd service file"

systemctl daemon-reload &>>"$LOGS_FILE"
systemctl enable shipping &>>"$LOGS_FILE"
systemctl start shipping &>>"$LOGS_FILE"
VALIDATE $? "Starting and enabling shipping service"

# -------------------- DATABASE SCHEMA LOAD --------------------
dnf install mysql -y &>>"$LOGS_FILE"
VALIDATE $? "Installing MySQL client"

# Capture Arguments
MYSQL_HOST=$1
DB_ROOT_PASSWORD=$2

# Check if both arguments are provided
if [ -z "$MYSQL_HOST" ] || [ -z "$DB_ROOT_PASSWORD" ]; then
    echo -e "$R Error: Missing arguments. $N"
    echo -e "Usage: sudo sh shipping.sh <MYSQL-IP-ADDRESS> <MYSQL-PASSWORD>"
    exit 1
fi

# Load Schema
mysql -h "$MYSQL_HOST" -uroot -p"$DB_ROOT_PASSWORD" < /app/db/schema.sql &>>"$LOGS_FILE"
VALIDATE $? "Loading Shipping Schema"

# Load App User
mysql -h "$MYSQL_HOST" -uroot -p"$DB_ROOT_PASSWORD" < /app/db/app-user.sql &>>"$LOGS_FILE"
VALIDATE $? "Loading App User"

# Load Master Data
mysql -h "$MYSQL_HOST" -uroot -p"$DB_ROOT_PASSWORD" < /app/db/master-data.sql &>>"$LOGS_FILE"
VALIDATE $? "Loading Master Data"

# Restart service after schema load to ensure connectivity
systemctl restart shipping &>>"$LOGS_FILE"
VALIDATE $? "Restarting shipping service"