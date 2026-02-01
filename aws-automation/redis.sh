#!/bin/bash
# ------------------------------------------------------------------
# Script Name : redis.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Install and configure redis for RoboShop
#   - Configure redis to backend services
#
# OS          : RHEL / Amazon Linux
# ------------------------------------------------------------------

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

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
echo "Configuring RoboShop redis..."

# -------------------- NGINX INSTALLATION --------------------
dnf module disable redis -y &>>"$LOGS_FILE"
VALIDATE $? "Disabling default Redis module"

dnf module enable redis:7 -y &>>"$LOGS_FILE"
VALIDATE $? "Enabling redis 7 module"

dnf install redis -y &>>"$LOGS_FILE"
VALIDATE $? "Installing Redis"

sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf &>>"$LOGS_FILE"
VALIDATE $? "Updating Redis bind address"

sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>>"$LOGS_FILE"
VALIDATE $? "Disabling Redis protected mode"

systemctl enable redis &>>"$LOGS_FILE"
systemctl start redis &>>"$LOGS_FILE"
VALIDATE $? "Starting redis service"