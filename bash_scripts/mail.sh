#!/bin/bash

# --- CAPTURE ARGUMENTS ---
# These variables come from the disk_usage.sh script calls.
TO_ADDRESS=$1       # Who gets the email?
SUBJECT=$2          # Email Subject
MESSAGE_BODY=$3     # The error list (e.g., "/ is at 90%")
ALERT_TYPE=$4       # Title of the alert (e.g., "High Disk Usage")
SERVER_IP=$5        # IP Address of the bad server
TO_TEAM=$6          # Greeting Name

# --- INPUT SANITIZATION (The Safety Check) ---
# Special characters like '/' or '[' can break the 'sed' command below.
# This command adds a backslash '\' before them to make them safe text.
FINAL_MESSAGE_BODY=$(echo $MESSAGE_BODY | sed -e 's/[]\/$*.^[]/\\&/g')

# --- TEMPLATE INJECTION (The Magic) ---
# We read 'template.html' and replace the placeholders (like TO_TEAM) with real data.
# s/FIND/REPLACE/g  -> This is the standard Substitution syntax.
FINAL_MESSAGE=$(sed -e "s/TO_TEAM/$TO_TEAM/g" \
                    -e "s/ALERT_TYPE/$ALERT_TYPE/g" \
                    -e "s/SERVER_IP/$SERVER_IP/g" \
                    -e "s/MESSAGE/$FINAL_MESSAGE_BODY/g" \
                    template.html)

# --- SEND EMAIL ---
# We pipe (|) the constructed email to msmtp to deliver it.
# Content-Type: text/html is MANDATORY for colors and bold text to work.
echo "Sending email to $TO_ADDRESS..."

{
    echo "To: $TO_ADDRESS"
    echo "Subject: $SUBJECT"
    echo "Content-Type: text/html"
    echo ""
    echo "$FINAL_MESSAGE"
} | msmtp "$TO_ADDRESS"

echo "Email sent successfully."