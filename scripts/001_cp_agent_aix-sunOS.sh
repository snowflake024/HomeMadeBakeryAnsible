#!/bin/bash

# Replace current agent files
## /usr/lib/check_mk_agent/*

source_dir="/tmp/ORA/usr/lib/check_mk_agent"
destination_dir="/usr/lib/check_mk_agent"

for file in $(find "$source_dir" -type f); do
    # Construct the relative path
    relative_path=${file#$source_dir}
    
    # Construct the destination path
    destination_path="$destination_dir$relative_path"
    
    # Ensure the parent directory exists in the destination
    mkdir -p "$(dirname "$destination_path")"
    
    # Copy the file to the destination directory
    cp "$file" "$destination_path"
    #echo "Copied: $destination_path"
    #echo "Would copy: $file to $destination_path"
done

## /usr/bin/
source_dir="/tmp/ORA/usr/bin/"
destination_dir="/usr/bin"
cp $source_dir/* $destination_dir

## /etc/check_mk
source_dir="/tmp/ORA/etc/check_mk"
destination_dir="/etc/check_mk"
cp $source_dir/mk_oracle.cfg $source_dir/sqlnet.ora $destination_dir
