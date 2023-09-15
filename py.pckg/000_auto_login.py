#!/usr/bin/env python3

import requests
import argparse

# A new instance of “ArgumentParser” object is created 
# and a short description for the program is supplied as an argument.
parser = argparse.ArgumentParser(description='A test program.')


# Set the login credentials and URL
url = 'https://vlcmkop010/sa_mon_ng/check_mk/login.py'
#username = int(sys.argv[1])
#password = int(sys.argv[2])

username = 'q400605'
password = 'j[P"HN`c_4c@^p'

# Set the payload data for the login form
data = {
    '_username': username,
    '_password': password,
    '_login': '1'
}

# Send a POST request to the login URL with the payload data
response = requests.post(url, data=data)

# Check if the login was successful
if response.status_code == 200 and 'Invalid credentials' not in response.text:
    # Get the session cookies from the response
    session_cookies = response.cookies.get_dict()
    print('Session cookies:', session_cookies)
else:
    print('Login failed.')

