#!/bin/bash
USERID=$(id -u)
if [ "$USERID" -ne 0 ]; then
echo "please runt this script  with root access"
exit 1
fi

install_package() {
    dnf install $1 -y
    if [ $? -ne 0 ]; then
    echo "Installing $1 .... FAILURE"
    exit 1
    else
        echo "Installing $1 ...SUCESS"
    fi
}

install_package nginx
install_package mysql
install_package nodejs