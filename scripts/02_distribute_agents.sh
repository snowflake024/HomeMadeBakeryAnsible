#!/bin/bash

set -x

# Define the directory path
local_agents_dir="/home/q400605ux/workdir/home_made_bakery/AGENTS"
remote_directory="/tmp/ORA"

# Cut the filename and extract the important bits
hostnames=()
for file in "$local_agents_dir"/*; do
    server=$(basename "$file" | cut -d'-' -f1)
    cmk=$(basename "$file" | cut -d'-' -f4 | sed 's/\.tar\.gz$//')
    os=$(basename "$file" | cut -d'-' -f3 | sed 's/\.tar\.gz$//')
    os_type+=("$os")
    hostnames+=("$server")
    cmk_hosts+=("$cmk")
done

# Loop over arrays simultaneously using the index variable
for ((i = 0; i < ${#hostnames[@]}; i++)); do

    server="${hostnames[i]}"
    cmk="${cmk_hosts[i]}"
    os="${os_type[i]}"

    echo "Processing agent for server: $server ($cmk)"
    
    # Construct the agent name
    agent_name="${server}-agent-${os}-${cmk}.tar.gz"
    tar_agent="${server}-agent-${os}-${cmk}.tar"   

    # Copy the agent over the remote side
    ssh $server "rm -rf $remote_directory"
    ssh $server "mkdir -p $remote_directory"
    scp "$local_agents_dir/$agent_name" "$server":$remote_directory
    
    # Process the agent archive
    # HPUX has issues when using gunzip through SSH
    case $os in
      AIX | SOLARIS)
        ssh $server "gunzip $remote_directory/$agent_name"
        ;;

      HPUX)
        ssh $server "/usr/contrib/bin/gunzip $remote_directory/$agent_name"
        ;;

      *)
        echo "Not a valid OS"
    esac

    ssh $server "cd $remote_directory && tar xf $remote_directory/$tar_agent"

    # Backup current working agent
    ssh $server "rm -rf /tmp/CMK_BACKUP.$(date +%F)"
    ssh $server "mkdir -p /tmp/CMK_BACKUP.$(date +%F)"
    ssh $server "cp -pr /etc/check_mk/ /tmp/CMK_BACKUP.$(date +%F)/"
    ssh $server "cp -pr /usr/bin/check_mk_agent /tmp/CMK_BACKUP.$(date +%F)/check_mk_agent"
    ssh $server "cp -pr /usr/lib/check_mk_agent /tmp/CMK_BACKUP.$(date +%F)/check_mk_agent_lib"
    
    # Replace current agent files    
    echo "REPLACING AGENT FILES"

    case $os in
      AIX | SOLARIS)
        ssh $server 'bash -s' < 001_cp_agent_aix-sunOS.sh
        ;;

      HPUX)
        ssh $server 'bash -s' < 002_cp_agent_hpux.sh
        ;;

      *)
        echo "Not a valid OS"
        ;;
    esac
done
