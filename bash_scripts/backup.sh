#!/bin/bash

# --- STRICT MODE (DevSecOps Best Practice) ---
# -e: Exit immediately if any command fails.
# -o pipefail: Catch errors even inside pipes.
set -e
set -o pipefail 
# --- VARIABLES ---
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/backup.log"
R="\e[31m"
G="\e[32m"
N="\e[0m"
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14} 
TIMESTAMP=$(date +%F-%H-%M-%S)
# --- FUNCTIONS ---
log(){
    # tee -a prints to screen AND appends to file at the same time
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $1" | tee -a $LOGS_FILE
}
USAGE(){
    echo -e "$R USAGE:: sudo $0 <SOURCE_DIR> <DEST_DIR> <DAYS(Optional)> $N"
    exit 1
}
# --- VALIDATIONS ---
# 1. Check Root
if [ $USERID -ne 0 ]; then
    echo -e "$R Error: Run with root access. $N"
    exit 1
fi

# 2. Check Arguments
if [ $# -lt 2 ]; then
    USAGE
fi

mkdir -p $LOGS_FOLDER $DEST_DIR # Creates logs and dest folder if missing

if [ ! -d $SOURCE_DIR ]; then
    log "$R Source $SOURCE_DIR does not exist $N"
    exit 1
fi
# --- MAIN LOGIC ---
log "Starting Backup. Source: $SOURCE_DIR | Dest: $DEST_DIR | Age: >$DAYS days"

# Step 1: Find files and save to a temporary list file (Handles spaces correctly)
# mktemp creates a safe, unique temporary file
FILE_LIST=$(mktemp)
find $SOURCE_DIR -name "*.log" -type f -mtime +$DAYS > $FILE_LIST

# Step 2: Check if file list is empty
if [ ! -s $FILE_LIST ]; then
    log "No old logs found. Skipping."
    rm -f $FILE_LIST
    exit 0
fi

log "Found $(wc -l < $FILE_LIST) files to archive."

# Step 3: Archive
ZIP_FILE_NAME="$DEST_DIR/app-logs-$TIMESTAMP.tar.gz"

# -T: Read files from the list we just created
# -z: Gzip compression
# -c: Create
# -f: File
tar -zcf $ZIP_FILE_NAME -T $FILE_LIST

# Step 4: Verify and Cleanup
if [ -f $ZIP_FILE_NAME ]; then
    log "Archiving... $G SUCCESS $N"
    log "Removing original files..."
    
    # Secure deletion using the same list
    # xargs reads the list and passes it to rm
    xargs -a $FILE_LIST rm -f
    
    log "Cleanup... $G COMPLETED $N"
else
    log "Archiving... $R FAILED $N"
    exit 1
fi

# Clean up the temporary list file
rm -f $FILE_LIST