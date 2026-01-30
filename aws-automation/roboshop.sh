#!/bin/bash
# ------------------------------------------------------------------
# Script Name : roboshop.sh
# Author      : Ramu Chelloju
# Purpose     :
#   1. Create EC2 instances using AWS CLI (RHEL AMI)
#   2. Fetch Public IP for frontend and Private IP for backend services
#   3. Automatically create/update DNS records in Route53
#
# Usage:
#   bash roboshop.sh frontend mongodb cart user shipping payment
#
# Prerequisites:
#   - AWS CLI configured (aws configure)
#   - IAM permissions for EC2 and Route53
# ------------------------------------------------------------------

set -e   # Exit immediately if any command fails (fail-fast approach)

# -------------------- STATIC CONFIGURATION --------------------
# These values usually remain constant for the project

SG_ID="sg-0736a66e08690c4f1"        # Security Group ID
AMI_ID="ami-0220d79f3f480ecf5"      # RHEL AMI ID
ZONE_ID="Z0106832348EIO1PNV416"     # Route53 Hosted Zone ID
DOMAIN_NAME="servicewiz.in"         # Base domain name

# -------------------- INPUT VALIDATION --------------------
# Ensure at least one service name is passed to the script

if [ $# -eq 0 ]; then
    echo "Usage: bash roboshop.sh <service1> <service2> ..."
    exit 1
fi

# -------------------- MAIN LOOP --------------------
# $@ represents all arguments passed to the script
# Example: frontend mongodb cart

for instance in "$@"
do
    echo "Creating EC2 instance for service: $instance"

    # ----------------------------------------------------------
    # 1️⃣ Create EC2 instance and capture Instance ID
    # ----------------------------------------------------------
    # $(...) is command substitution → stores command output in variable

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "t3.micro" \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    echo "EC2 instance created with ID: $INSTANCE_ID"

    # ----------------------------------------------------------
    # 2️⃣ Decide IP type and DNS record name
    # ----------------------------------------------------------
    # Frontend → Public IP + root domain
    # Backend  → Private IP + subdomain

    if [ "$instance" == "frontend" ]; then
        # Fetch Public IP for frontend
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text)

        RECORD_NAME="$DOMAIN_NAME"
    else
        # Fetch Private IP for backend services
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)

        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi

    echo "Resolved IP Address: $IP"
    echo "Updating DNS record: $RECORD_NAME"

    # ----------------------------------------------------------
    # 3️⃣ Create or Update Route53 DNS record
    # ----------------------------------------------------------
    # Using single quotes for JSON avoids escaping (\")
    # Variables are injected by breaking out of single quotes

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$ZONE_ID" \
        --change-batch '
        {
            "Comment": "Updating record",
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$RECORD_NAME'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                        ]
                    }
                }
            ]
        }
        '

    echo "DNS record updated successfully for $instance"
    echo "--------------------------------------------------"

done

echo "All services processed successfully."
