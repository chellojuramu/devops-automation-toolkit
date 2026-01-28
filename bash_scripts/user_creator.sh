#!/bin/bash
USERNAME=$1
echo "the username requested is: $USERNAME"
if [ -z "$USERNAME" ]; then
    echo "Error: You forgot to provide a username!"
    echo "Usage: ./user_creator.sh <username>"
    exit 1
fi