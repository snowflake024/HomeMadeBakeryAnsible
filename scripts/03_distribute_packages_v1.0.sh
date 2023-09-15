#!/bin/bash

#set -x

# Establishing variables from configuration
while IFS='=' read -r key value; do
    case "$key" in
        "LOCAL_PACKAGE_DIR")
            LOCAL_PACKAGE_DIR="$value"
            ;;
        "PACKAGE_SERVER_LIST")
            PACKAGE_SERVER_LIST="$value"
            ;;
	"REMOTE_PACKAGE_DIR")
            REMOTE_PACKAGE_DIR="$value"
	    ;;
        *)
    esac
done < ../bakery.conf


# For singular files only
FILE=$(ls -1 $LOCAL_PACKAGE_DIR)

for server in $(cat "$PACKAGE_SERVER_LIST"); do
    
    # delete accidentaly created dir as file
    if [ -f $REMOTE_PACKAGE_DIR ]; then
        ssh $server "rm -f $REMOTE_PACKAGE_DIR"
    fi
   
     # Check if AGENT's dir exist
    if [ ! -d $REMOTE_PACKAGE_DIR ]; then
        ssh $server "mkdir $REMOTE_PACKAGE_DIR"
    fi
    

    # Assume that the files are with correct permissions to start with
    echo "Transfering $FILE to $server:$REMOTE_PACKAGE_DIR"
    scp -pr $LOCAL_PACKAGE_DIR/* $server:$REMOTE_PACKAGE_DIR/
    
    #TEST RUN ONLY FOR executable files, does not work for multiple files in $LOCAL_PACKAGE_DIR
    #ssh $server "chmod 755 $REMOTE_PACKAGE_DIR/$FILE" 
    echo ""
done


