#!/bin/bash

# --- CONFIGURATION ---
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE="/tmp/$SCRIPT_NAME-$TIMESTAMP.log"

# --- COLORS (For Professional Output) ---
R="\e[31m"  # Red
G="\e[32m"  # Green
N="\e[0m"   # Normal (Reset)

# --- FUNCTIONS ---
# This function checks if the previous command failed
validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2... $R FAILURE $N"
        exit 1
    else
        echo -e "$2... $G SUCCESS $N"
    fi
}

# --- SCRIPT START ---

# 1. Check Root Access
if [ $USERID -ne 0 ]; then
    echo -e "$R Error: Please run this script with root access. $N"
    exit 1
fi

# 2. Update System (Good Practice)
echo "Updating system repositories..."
dnf update -y &>> $LOGFILE
validate $? "Updating System"

# 3. Install Nginx
echo "Installing Nginx..."
# &>> redirects all output (success and errors) to the log file, keeping the screen clean
dnf install nginx -y &>> $LOGFILE
validate $? "Installing Nginx"

# 4. Start Service
echo "Starting Nginx Service..."
systemctl start nginx &>> $LOGFILE
validate $? "Starting Nginx"

echo -e "$G Script completed successfully. Logs saved to: $LOGFILE $N"