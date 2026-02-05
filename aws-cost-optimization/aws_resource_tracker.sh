#!/bin/bash

#################################################################
# Author: Ramu
# Date: 2026-02-05
# Version: v1
# Description: AWS Resource Tracker with Email Reporting
#################################################################

# --- CONFIGURATION ---
LOGS_FOLDER="/var/log/aws_resource_tracker"
mkdir -p "$LOGS_FOLDER"

# 1. UNIQUE FILENAME: Adds the date (e.g., tracker-2026-02-05.log)
SCRIPT_NAME=$(basename "$0" .sh)
TIMESTAMP=$(date +%F)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

# --- COLORS ---
R="\e[31m"
G="\e[32m"
N="\e[0m"

# --- HELPER FUNCTION ---
print_header() {
    echo "------------------------------------------------" >> $LOG_FILE
    echo "  $1" >> $LOG_FILE
    echo "------------------------------------------------" >> $LOG_FILE
}

# --- START SCRIPT ---
echo "Generating Report: $(date "+%Y-%m-%d %H:%M:%S")" > $LOG_FILE

# 1. S3 BUCKETS
print_header "S3 BUCKETS"
aws s3 ls >> $LOG_FILE

# 2. EC2 INSTANCES
print_header "EC2 INSTANCES (ID & State)"
aws ec2 describe-instances \
    | jq -r '.Reservations[].Instances[] | "\(.InstanceId): \(.State.Name)"' >> $LOG_FILE

# 3. LAMBDA FUNCTIONS
print_header "LAMBDA FUNCTIONS"
aws lambda list-functions \
    | jq -r '.Functions[] | "\(.FunctionName): \(.Runtime)"' >> $LOG_FILE

# 4. IAM USERS
print_header "IAM USERS"
aws iam list-users \
    | jq -r '.Users[].UserName' >> $LOG_FILE

# 5. EBS VOLUMES
print_header "EBS VOLUMES (Size & State)"
aws ec2 describe-volumes \
    | jq -r '.Volumes[] | "\(.VolumeId): \(.Size) GB - \(.State)"' >> $LOG_FILE

# --- END & NOTIFY ---
echo "Report generated at: $LOG_FILE"

# --- EMAIL INTEGRATION (The Handover) ---
# 1. Read the log file into a variable
REPORT_CONTENT=$(cat $LOG_FILE)

# 2. Call the Mail Script
# Usage: sh mail.sh <TO> <SUBJECT> <BODY> <TITLE> <IP> <TEAM>
# Note: We use "localhost" for IP since this is a report, not an error alert.
echo "Sending Email Report..."
sh mail.sh "chelloju@outlook.com" "Daily AWS Resource Report" "$REPORT_CONTENT" "AWS Cost Tracker" "localhost" "DevOps Team"