#!/bin/bash
USERID=$(id -u)
if [ "$USERID" -ne 0 ]; then
echo "please runt this script  with root access"
exit 1
fi

install_package() {
    apt update -y
    apt install -y "$1"
    if [ $? -ne 0 ]; then
    echo "Installing $1 .... FAILURE"
    exit 1
    else
        echo "Installing $1 ...SUCESS"
    fi
}

install_package nginx
install_package mysql-server
install_package nodejs