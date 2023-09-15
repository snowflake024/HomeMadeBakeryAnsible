#!/bin/bash

#set -x

# Establishing variables from configuration
while IFS='=' read -r key value; do
    case "$key" in
        "LOCAL_AGENT_LOCATION")
            LOCAL_AGENT_LOCATION="$value"
            ;;
        "REMOTE_AGENT_LOCATION")
            REMOTE_AGENT_LOCATION="$value"
            ;;
        "MASTER_CHECKMK_NODE")
            server="$value"
            ;;
        "PYTHON_PACKAGE")
            PYTHON_PACKAGE="$value"
            ;;
        "REMOTE_BAKERY_LOCATION")
            REMOTE_BAKERY_LOCATION="$value"
            ;;
        *)
            echo ""
            
    esac
done < ../bakery.conf

# Establish staging directory
ssh $server "rm -rf $REMOTE_BAKERY_LOCATION && mkdir -p $REMOTE_AGENT_LOCATION"

# Copy needed files 
scp -r $PYTHON_PACKAGE/* $server:$REMOTE_BAKERY_LOCATION

# Run the python script
ssh $server "cd $REMOTE_BAKERY_LOCATION && python3 00_fetch_agent_from_bakery.py"

# Fetch agents from remote to local
bash 01_fetch_baked_agents_from_remote.sh

# Cleanup
ssh $server "rm -rf $REMOTE_BAKERY_LOCATION"
