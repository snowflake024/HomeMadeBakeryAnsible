#!/bin/bash

ssh i23lpar26 "ls /tmp/CMK_BACKUP.$(date +%F)"

if [ $? -eq 0 ]; then
   echo "DIR EXISTS"
else
   echo "DIR DOES NOT EXIST"
fi

