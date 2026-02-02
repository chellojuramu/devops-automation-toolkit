#!/bin/bash
# -------------------- DISPATCH SETUP --------------------
# Author: Ramu Chelloju
# Purpose: Install and configure GoLang-based Dispatch service

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$(pwd)

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Root Check
if [ "$USERID" -ne 0 ]; then
    echo -e "$R Please run with root access $N"
    exit 1
fi

mkdir -p "$LOGS_FOLDER"

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOGS_FILE"
    fi
}

# -------------------- INSTALL GOLANG --------------------
dnf install golang -y &>>"$LOGS_FILE"
VALIDATE $? "Installing GoLang"

# -------------------- APPLICATION USER --------------------
id roboshop &>>"$LOGS_FILE"
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>"$LOGS_FILE"
    VALIDATE $? "Creating roboshop user"
else
    echo -e "User already exists ... $Y SKIPPING $N"
fi

# -------------------- DEPLOY APPLICATION --------------------
mkdir -p /app
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>"$LOGS_FILE"
VALIDATE $? "Downloading Dispatch artifacts"

cd /app
rm -rf /app/*
unzip /tmp/dispatch.zip &>>"$LOGS_FILE"
VALIDATE $? "Extracting Dispatch code"

# -------------------- BUILD BINARY --------------------
# GoLang builds a single executable binary
go mod init dispatch &>>"$LOGS_FILE"
go get &>>"$LOGS_FILE"
go build &>>"$LOGS_FILE"
VALIDATE $? "Building Dispatch binary"

# -------------------- SYSTEMD SETUP --------------------
cp "$SCRIPT_DIR/dispatch.service" /etc/systemd/system/dispatch.service
VALIDATE $? "Copying service file"

systemctl daemon-reload &>>"$LOGS_FILE"
systemctl enable dispatch &>>"$LOGS_FILE"
systemctl start dispatch &>>"$LOGS_FILE"
VALIDATE $? "Starting Dispatch service"