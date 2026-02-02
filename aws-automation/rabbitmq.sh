#!/bin/bash
# ------------------------------------------------------------------
# Script Name : rabbitmq.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Install and configure rabbitmq for RoboShop
#   - Configure rabbitmq to backend services
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
echo "Configuring RoboShop rabbitmq..."

# -------------------- REPOSITORY SETUP --------------------
# Copy the repo file from your script directory to the system directory
cp "$SCRIPT_DIR/rabbitmq.repo" /etc/yum.repos.d/rabbitmq.repo &>>"$LOGS_FILE"
VALIDATE $? "Setting up RabbitMQ repository"

# -------------------- INSTALLATION --------------------
dnf install rabbitmq-server -y &>>"$LOGS_FILE"
VALIDATE $? "Installing RabbitMQ Server"

# -------------------- SERVICE MANAGEMENT --------------------
systemctl enable rabbitmq-server &>>"$LOGS_FILE"
systemctl start rabbitmq-server &>>"$LOGS_FILE"
VALIDATE $? "Starting and enabling RabbitMQ service"

# -------------------- USER CONFIGURATION (Idempotent) --------------------
# Check if the 'roboshop' user already exists to avoid errors on re-run
rabbitmqctl list_users | grep roboshop &>>"$LOGS_FILE"

if [ $? -ne 0 ]; then
    echo -e "Creating roboshop user... $Y RUNNING $N"
    # Create user with password roboshop123
    rabbitmqctl add_user roboshop roboshop123 &>>"$LOGS_FILE"
    VALIDATE $? "Adding roboshop user to RabbitMQ"
    
    # Set permissions: -p / (on the default virtual host) for user "roboshop"
    # ".*" ".*" ".*" gives configure, write, and read permissions on all resources
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>"$LOGS_FILE"
    VALIDATE $? "Setting roboshop user permissions"
else
    echo -e "Roboshop user already exists... $Y SKIPPING $N"
fi