#!/bin/bash

# --- CONFIGURATION & COLORS ---
# R=Red (Danger), G=Green (Safe), N=No Color (Reset)
R="\e[31m"
G="\e[32m"
N="\e[0m"

# The Threshold: If disk usage is > 5%, send an alert. 
# (Set this to 75 or 80 in a real company)
USAGE_THRESHOLD=5
MESSAGE=""

# --- HELPER: GET INSTANCE IP ---
# We need the IP so the email tells us WHICH server is having issues.
# curl fetches the IP from AWS Metadata service.
IP_ADDRESS=$(curl http://54.234.246.127/latest/meta-data/local-ipv4)

# --- HELPER: CHECK DISK USAGE ---
# df -hT : Get disk usage in Human readable format.
# grep -v Filesystem : Remove the header line ("Filesystem Type Size...") so we only have data.
DISK_USAGE=$(df -hT | grep -v Filesystem)

# --- MAIN LOOP ---
# We feed the disk info into this while loop line-by-line using `<<<` at the bottom.
while IFS= read -r line
do
    # EXTRACTING DATA FROM THE LINE
    # $6 is the Usage Column (e.g., "25%"). `cut -d%` removes the "%" symbol.
    USAGE=$(echo $line | awk '{print $6}' | cut -d "%" -f1)
    
    # $7 is the Partition Name (e.g., "/" or "/home")
    PARTITION=$(echo $line | awk '{print $7}')

    # CHECKING FOR DANGER
    # -ge means "Greater than or Equal to"
    if [ $USAGE -ge $USAGE_THRESHOLD ]; then
        # Append the error to our message variable.
        # <br> is HTML code for a "New Line" (since the email is HTML).
        MESSAGE+="High Disk usage on $PARTITION: $USAGE% <br>"
    fi

done <<< $DISK_USAGE

# --- FINAL DECISION ---
echo -e "Message: $MESSAGE"

# If MESSAGE is not empty (-n), it means we found an error. Send Email.
if [ -n "$MESSAGE" ]; then
    echo -e "$R Critical Issue Found! Sending Alert... $N"
    
    # CALL THE MAIL SCRIPT
    # We pass arguments: "To Address" "Subject" "Body" "Alert Type" "Server IP" "Greeting"
    sh mail.sh "chelloju@outlook.com" "High Disk Usage Alert" "$MESSAGE" "High Disk Usage" "$IP_ADDRESS" "DevOps Team"
else
    echo -e "$G All Systems Normal. No Alert Sent. $N"
fi