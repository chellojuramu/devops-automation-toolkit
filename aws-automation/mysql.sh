#!/bin/bash
# ------------------------------------------------------------------
# Script Name : mysql.sh
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
echo "Configuring RoboShop mysql..."

# -------------------- MySQL INSTALLATION --------------------
dnf install mysql-server -y &>>"$LOGS_FILE"
VALIDATE $? "Installing MySQL Server"

# -------------------- START SERVICE --------------------
systemctl enable mysqld &>>"$LOGS_FILE"
systemctl start mysqld &>>"$LOGS_FILE"
VALIDATE $? "Starting and enabling MySQL service"

# Capture the password from the first argument
# If the user doesn't provide one, it will be empty
DB_ROOT_PASSWORD=$1

# Root Check and Validation functions stay the same...

# -------------------- SECURE INSTALLATION --------------------
# Check if the password was even provided
if [ -z "$DB_ROOT_PASSWORD" ]; then
    echo -e "$R Error: Password not provided. $N"
    echo -e "Usage: sudo sh mysql.sh <password>"
    exit 1
fi

# Use the variable in your connection check
mysql -u root -p"$DB_ROOT_PASSWORD" -e 'show databases;' &>>"$LOGS_FILE"

if [ $? -ne 0 ]; then
    echo -e "Configuring root password... $Y RUNNING $N"
    mysql_secure_installation --set-root-pass "$DB_ROOT_PASSWORD" &>>"$LOGS_FILE"
    VALIDATE $? "Setting MySQL root password"
else
    echo -e "MySQL root password already set... $Y SKIPPING $N"
fi