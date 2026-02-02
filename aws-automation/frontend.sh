#!/bin/bash
# ------------------------------------------------------------------
# Script Name : frontend.sh
# Author      : Ramu Chelloju
# Purpose     :
#   - Install and configure Nginx frontend for RoboShop
#   - Deploy static frontend content
#   - Configure Nginx reverse proxy to backend services
#
# OS          : RHEL / Amazon Linux
# ------------------------------------------------------------------

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0")
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# -------------------- BACKEND SERVICE IPs --------------------
CATALOGUE_IP="172.31.3.3"
USER_IP="172.31.10.11"
CART_IP="172.31.10.12"
SHIPPING_IP="172.31.10.13"
PAYMENT_IP="172.31.10.14"

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

echo "Configuring RoboShop Frontend..."

# -------------------- NGINX INSTALLATION --------------------
dnf module disable nginx -y &>>"$LOGS_FILE"
VALIDATE $? "Disabling default Nginx module"

dnf module enable nginx:1.24 -y &>>"$LOGS_FILE"
VALIDATE $? "Enabling Nginx 1.24 module"

dnf install nginx -y &>>"$LOGS_FILE"
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>"$LOGS_FILE"
systemctl start nginx &>>"$LOGS_FILE"
VALIDATE $? "Starting Nginx service"

# -------------------- FRONTEND CONTENT --------------------
rm -rf /usr/share/nginx/html/* &>>"$LOGS_FILE"
VALIDATE $? "Removing default Nginx content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>"$LOGS_FILE"
VALIDATE $? "Downloading frontend content"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>"$LOGS_FILE"
VALIDATE $? "Extracting frontend content"

# -------------------- NGINX REVERSE PROXY CONFIG --------------------
cat >/etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    access_log  /var/log/nginx/access.log;
    sendfile        on;
    keepalive_timeout 65;

    server {
        listen 80;
        root /usr/share/nginx/html;

        location /images/ {
            expires 5s;
            try_files \$uri /images/placeholder.jpg;
        }

        location /api/catalogue/ { proxy_pass http://${CATALOGUE_IP}:8080/; }
        location /api/user/ { proxy_pass http://${USER_IP}:8080/; }
        location /api/cart/ { proxy_pass http://${CART_IP}:8080/; }
        location /api/shipping/ { proxy_pass http://${SHIPPING_IP}:8080/; }
        location /api/payment/ { proxy_pass http://${PAYMENT_IP}:8080/; }

        location /health {
            stub_status on;
            access_log off;
        }
    }
}
EOF

VALIDATE $? "Configuring Nginx reverse proxy"

# -------------------- RESTART NGINX --------------------
systemctl restart nginx &>>"$LOGS_FILE"
VALIDATE $? "Restarting Nginx"

echo -e "$G RoboShop Frontend configured successfully $N"
