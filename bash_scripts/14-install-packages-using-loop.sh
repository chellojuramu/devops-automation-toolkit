#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

if [ "$USERID" -ne 0 ]; then
    echo "Please run this script with root access" | tee -a "$LOGS_FILE"
    exit 1
fi

mkdir -p "$LOGS_FOLDER"

apt update -y &>> "$LOGS_FILE"

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo "$2 ... FAILURE" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo "$2 ... SUCCESS" | tee -a "$LOGS_FILE"
    fi
}

for package in "$@"
do
    dpkg -s "$package" &>> "$LOGS_FILE"
    if [ $? -ne 0 ]; then
        echo "$package not installed, installing now" | tee -a "$LOGS_FILE"
        apt install -y "$package" &>> "$LOGS_FILE"
        VALIDATE $? "Installing $package"
    else
        echo "$package already installed, skipping" | tee -a "$LOGS_FILE"
    fi
done
