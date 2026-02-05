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
SCRIPT_NAME=$(basename "$0" .sh)
TIMESTAMP=$(date +%F)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

# --- HELPER FUNCTION ---
print_header() {
    # We add a special marker "###" so our converter knows this is a Header
    echo "### $1" >> $LOG_FILE
}

# --- START TRACKING (Same logic, just ensuring clean output) ---
echo "Generating Report..." > $LOG_FILE

# 1. S3
print_header "S3 Buckets"
aws s3 ls | awk '{print $3}' >> $LOG_FILE

# 2. EC2
print_header "EC2 Instances"
aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "\(.InstanceId): \(.State.Name)"' >> $LOG_FILE

# 3. Lambda
print_header "Lambda Functions"
aws lambda list-functions | jq -r '.Functions[] | "\(.FunctionName): \(.Runtime)"' >> $LOG_FILE

# 4. IAM
print_header "IAM Users"
aws iam list-users | jq -r '.Users[].UserName' >> $LOG_FILE

# 5. EBS
print_header "EBS Volumes"
aws ec2 describe-volumes | jq -r '.Volumes[] | "\(.VolumeId): \(.Size) GB - \(.State)"' >> $LOG_FILE


# --- EMAIL INTEGRATION (THE NEW MAGIC) ---

# We use awk to convert the text log into HTML Table Rows
# 1. If line starts with "###", it's a Category Header.
# 2. If line contains "running" or "in-use", make it GREEN.
# 3. If line contains "stopped", make it RED.
# 4. If line contains "available", make it YELLOW.

HTML_BODY=$(awk '
BEGIN { FS=":" } 
/^###/ { 
    print "<tr class=\"category-row\"><td colspan=\"2\">" substr($0, 5) "</td></tr>" 
} 
!/^###/ && NF > 0 { 
    status = "bg-gray"
    if ($0 ~ /running|in-use/) status = "bg-green"
    if ($0 ~ /stopped/) status = "bg-red"
    if ($0 ~ /available/) status = "bg-yellow"
    
    # Check if there is a colon separator (like InstanceID : Status)
    if (NF == 2) {
        print "<tr><td><b>" $1 "</b></td><td><span class=\"badge " status "\">" $2 "</span></td></tr>"
    } else {
        # No colon (like S3 buckets), just print the name
        print "<tr><td>" $1 "</td><td><span class=\"badge bg-gray\">Active</span></td></tr>"
    }
}' $LOG_FILE)

# Send the Email
echo "Sending HTML Report..."
TODAY=$(date)
# We replace TODAY_DATE in the template manually using sed
sed -i "s/TODAY_DATE/$TODAY/g" template.html

sh mail.sh "chelloju@outlook.com" "Daily AWS Resource Report" "$HTML_BODY" "AWS Tracker" "localhost" "DevOps Team"