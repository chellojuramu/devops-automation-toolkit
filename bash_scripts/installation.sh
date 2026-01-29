#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0]; then
    echo "Please run this script with root user access"
    exit 1
fi

echo "Installing Nginx"
dnf install nginx -y

if [ $? -ne 0]; then
    echo "installing nginx....FAILURE"
    exit 1
else
    echo "Installing Nginx...SUCCESS"
fi