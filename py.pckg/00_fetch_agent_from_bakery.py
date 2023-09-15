#!/usr/bin/env python3

import re
import requests
import subprocess
import os
import configparser

# Configparser object
remote_conf="./remote_py.conf"
config = configparser.ConfigParser()
config.read(remote_conf)

# Global vars
global download_url
output_dir = config.get('input', 'OUTPUT_DIR')
global output_file

# Run the 'auto_login.py' script using subprocess
result = subprocess.run(['./000_auto_login.py'], stdout=subprocess.PIPE, universal_newlines=True)

# Get the standard output (session cookies) from the result
session_cookies = result.stdout.strip()

# Parse the session cookies to get the 'auth_sa_mon_ng' value
session_cookies = session_cookies.split(' ')
sad = session_cookies[3]
auth_sa_mon_ng_value = re.search(r"'\s*([^']+?)\s*'", sad).groups()[0]

# Define the file path
file_path = config.get('input', 'INPUT_DATA')

# Read the file and assign its contents to a list variable
with open(file_path, "r") as file:
    my_list = file.readlines()

for entry in my_list:
    # serverS is the canonical name in CheckMK, which many times differ from the one used to connect to the server
    # OS is needed to fetch the proper agent from bakery
    # real_host is passed in the downloaded agent name in order for the distribution to address the server properly
    real_host, servers, os_type = entry.split()

    print("Starting download of ...")
    print(f"OS - {os_type}")
    print(f"CMK - {servers}")
    print(f"HOST - {real_host}")

    # Agents packages page
    url = f'https://vlcmkop010/sa_mon_ng/check_mk/wato.py?csrf_token=40302f47-32e0-4f19-abdd-c8389d9c8977' \
          f'&filled_in=inpage_search_form&search={servers}&mode=agents&reset_url=wato.py%3Fmode%3Dagents&submit=#'

    response = requests.get(url, headers={
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Cookie': f'auth_sa_mon_ng={auth_sa_mon_ng_value}',  # Use the auth_sa_mon_ng_value here
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
    })

    # Check the HTTP status code
    if response.status_code == 200:
        # print("Request succeeded!")

        # Check if content is for the right server
        head_content = response.text

        # Use regular expression to find all tags that contain "hash="
        tags_with_hash = re.findall(r'<[^>]*hash=[^>]*>', head_content)

        # Initialize an empty dictionary to store the results
        result_dict = {}

        # Iterate through the matched tags and extract the part after "os="
        for tag in tags_with_hash:
            tag_filter = re.search(r'href=\"([^&]+.)', tag).groups()[0]
            os_value = re.search(r'os=([^&"]+)', tag)
            if os_value:
                os_value = os_value.group(1)
                result_dict[os_value] = tag_filter

        d_url = "https://vlcmkop010/sa_mon_ng/check_mk/"
        if os_type == "AIX":
            print("")
            download_url = f"{d_url}{result_dict['aix_tgz']}os=aix_tgz"
            output_file = f"{real_host}-agent-AIX-{servers}.tar.gz"
        elif os_type == "SunOS":
            print("")
            download_url = f"{d_url}{result_dict['solaris_tgz']}os=solaris_tgz"
            output_file = f"{real_host}-agent-SOLARIS-{servers}.tar.gz"
        elif os_type == "HP-UX":
            print("")
            download_url = f"{d_url}{result_dict['aix_tgz']}os=aix_tgz"
            output_file = f"{real_host}-agent-HPUX-{servers}.tar.gz"

#        output_dir = config.get('input', 'OUTPUT_DIR')
        
        # Clean the output agent directory 
        try:
            for item in os.listdir(output_dir):
                item_path = os.path.join(output_dir, item)
                if os.path.isfile(item_path):
                    os.remove(item_path)
                elif os.path.isdir(item_path):
                    delete_directory_contents(item_path)
                    os.rmdir(item_path)
        except Exception as e:
                print("Error:", e)
        
        # Commence downloading
        try:
            download = requests.get(download_url, headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
                'Accept-Encoding': 'gzip, deflate, br',
                'DNT': '1',
                'Connection': 'keep-alive',
                'Cookie': f'auth_sa_mon_ng={auth_sa_mon_ng_value}',  # Use the auth_sa_mon_ng_value here
                'Upgrade-Insecure-Requests': '1',
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'none',
                'Sec-Fetch-User': '?1',
            })

            # Check if the request was successful (status code 200)
            if download.status_code == 200:
                with open(os.path.join(output_dir, output_file), "wb") as f:
                    f.write(download.content)
                print(f"File downloaded successfully: {os.path.join(output_dir, output_file)}")
                print("=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+=_=+")
            else:
                print(f"Failed to download the file. Status code: {download.status_code}\n")

        except requests.exceptions.RequestException as e:
            print(f"An error occurred: {e}")

    elif response.status_code == 307:
        # Handle the redirect here if needed
        redirect_url = response.headers.get('Location')
        print(f"Received redirect to: {redirect_url}")

    else:
        # Handle other status codes if needed
        print(f"Received status code: {response.status_code}")

