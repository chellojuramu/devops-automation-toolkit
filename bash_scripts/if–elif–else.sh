#!/bin/bash

NUMBER=$1

if [ -z "$NUMBER" ]; then
  echo "Usage: $0 <number>"
  exit 1
fi

if [ "$NUMBER" -gt 20 ]; then
  echo "Given number $NUMBER is greater than 20"
elif [ "$NUMBER" -eq 20 ]; then
  echo "Given number $NUMBER is equal to 20"
else
  echo "Given number $NUMBER is less than 20"
fi
