#!/bin/bash

# --- CAPTURE ARGUMENTS ---
TO_ADDRESS=$1
SUBJECT=$2
MESSAGE_BODY=$3
ALERT_TYPE=$4
SERVER_IP=$5
TO_TEAM=$6

# --- STEP 1: SAVE BODY TO FILE ---
# We save the report to a temp file. This prevents the "sed" crash.
BODY_FILE=$(mktemp)
echo "$MESSAGE_BODY" > "$BODY_FILE"

# --- STEP 2: PREPARE EMAIL ---
FINAL_EMAIL=$(mktemp)

# 2a. Replace simple variables (Team Name, IP, Alert Type) using standard sed
sed -e "s/TO_TEAM/$TO_TEAM/g" \
    -e "s/ALERT_TYPE/$ALERT_TYPE/g" \
    -e "s/SERVER_IP/$SERVER_IP/g" \
    template.html > "$FINAL_EMAIL.tmp"

# 2b. INJECT THE REPORT BODY (The Fix)
# We use the 'r' command to READ the file, instead of 's' to replace text.
# This creates a safe way to insert huge reports.
sed -e "/MESSAGE/r $BODY_FILE" \
    -e "/MESSAGE/d" \
    "$FINAL_EMAIL.tmp" > "$FINAL_EMAIL"

# --- STEP 3: SEND EMAIL ---
echo "Sending email to $TO_ADDRESS..."
{
    echo "To: $TO_ADDRESS"
    echo "Subject: $SUBJECT"
    echo "Content-Type: text/html"
    echo ""
    cat "$FINAL_EMAIL"
} | msmtp "$TO_ADDRESS"

# --- CLEANUP ---
rm -f "$BODY_FILE" "$FINAL_EMAIL" "$FINAL_EMAIL.tmp"