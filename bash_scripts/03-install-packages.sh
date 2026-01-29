#!/bin/bash
# -------------------------------------------------
# Script Name : install_packages.sh
# Author      : Ramu Chelloju
# Purpose     : Install required packages safely on Ubuntu
# -------------------------------------------------

# Get the User ID of the person running the script
# Root user always has UID = 0
USERID=$(id -u)

# Check if the script is being run as root
# Package installation requires root privileges
if [ "$USERID" -ne 0 ]; then
    echo "Please run this script with root access (sudo)"
    exit 1
fi

# -------------------------------------------------
# Function: install_package
# Argument: $1 -> package name (nginx, mysql-server, nodejs)
# -------------------------------------------------
install_package() {

    # Update package index (best practice before installing)
    apt update -y

    # Install the package passed as first argument
    apt install -y "$1"

    # $? stores the exit status of the last command
    # 0   -> success
    # !=0 -> failure
    if [ $? -ne 0 ]; then
        echo "Installing $1 ... FAILURE"
        exit 1
    else
        echo "Installing $1 ... SUCCESS"
    fi
}

# -------------------------------------------------
# Function calls
# Each call passes a package name as argument
# -------------------------------------------------
install_package nginx
install_package mysql-server
install_package nodejs
