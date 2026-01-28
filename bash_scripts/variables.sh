#!/bin/bash
START_TIME=$(date +%s)

echo "please enter your username:: "
read USER_NAME
echo "username is $USER_NAME"

echo "please enter your password::"
read -s PASSWORD
#-s hides the what u enter
#VAR_NAME=$(command)
#echo "script executed at: $VAR_NAME
TIMESTAMP=$(date)
echo "Script executed at: $START_TIME"
sleep 10

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME-$START_TIME))

echo "Script executed in : $TOTAL_TIME"

