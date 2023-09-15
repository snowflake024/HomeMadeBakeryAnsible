#!/bin/bash

# Establishing variables from configuration
while IFS='=' read -r key value; do
    case "$key" in
        "LOCAL_AGENT_LOCATION")
            local_dir="$value"
            ;;
        "REMOTE_AGENT_LOCATION")
            remote_dir="$value"
            ;;
        "MASTER_CHECKMK_NODE")
            remote_host="$value"
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

# Check if AGENT's dir exist
if [ ! -d $local_dir ]; then
    mkdir -p "$local_dir"
fi

# Remove all files from the destination directory before fetching from the remote host
rm -rf "$local_dir"/*

# Fetch agent files from the remote machine
echo "Download starting .. Saving to $local_dir"
scp -r "$remote_host:$remote_dir"/* "$local_dir"

# Count the files moved
num_files_moved=$(ls -1 "$local_dir" | wc -l)

# List the files moved
echo -e  "\nNumber of fetched files: $num_files_moved"
ls -1 "$local_dir"

