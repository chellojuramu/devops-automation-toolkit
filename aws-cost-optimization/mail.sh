#!/bin/bash

# --- CAPTURE ARGUMENTS ---
TO_ADDRESS=$1
SUBJECT=$2
MESSAGE_BODY=$3
ALERT_TYPE=$4
SERVER_IP=$5
TO_TEAM=$6

# --- SANITIZATION ---
# This is crucial for reports! 
# We escape special characters so the large report doesn't crash the 'sed' command.
# formatting trick: We don't change newlines here; we handle them in HTML (pre tag).
FINAL_MESSAGE_BODY=$(echo "$MESSAGE_BODY" | sed -e 's/[]\/$*.^[]/\\&/g')

# --- TEMPLATE MERGE ---
# We inject the data into template.html
FINAL_MESSAGE=$(sed -e "s/TO_TEAM/$TO_TEAM/g" \
                    -e "s/ALERT_TYPE/$ALERT_TYPE/g" \
                    -e "s/SERVER_IP/$SERVER_IP/g" \
                    -e "s/MESSAGE/$FINAL_MESSAGE_BODY/g" \
                    template.html)

# --- SEND EMAIL ---
echo "Sending email to $TO_ADDRESS..."
{
    echo "To: $TO_ADDRESS"
    echo "Subject: $SUBJECT"
    echo "Content-Type: text/html"
    echo ""
    echo "$FINAL_MESSAGE"
} | msmtp "$TO_ADDRESS"