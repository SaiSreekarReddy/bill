import paramiko
import time
import getpass
import subprocess
import os

def detect_server_type(channel):
    """Detect the server type based on the presence of directories in /opt."""
    channel.send('cd /opt\n')
    time.sleep(1)
    channel.send('ls\n')
    time.sleep(1)
    
    server_types = ["springboot", "jboss", "splunk"]
    
    detected_type = "Regular"  # Default to regular

    if channel.recv_ready():
        output = channel.recv(1024).decode('utf-8').strip().splitlines()
        for line in output:
            for server_type in server_types:
                if server_type in line:
                    detected_type = server_type.capitalize()
                    break
            if detected_type != "Regular":
                break
    
    return detected_type

def ssh_to_server():
    # Prompt user for server details
    host = input("Enter the server IP address: ")
    username = input("Enter your SSH username: ")
    password = getpass.getpass("Enter your SSH password: ")

    # Initialize the SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        # Connect to the server
        ssh.connect(host, username=username, password=password)

        # Open an interactive shell session
        channel = ssh.invoke_shell()

        # Execute the sudo su command
        channel.send('sudo su\n')
        time.sleep(1)
        channel.send(password + '\n')
        time.sleep(1)  # Give it some time to switch users

        # Read the output of the commands
        while channel.recv_ready():
            output = channel.recv(1024).decode('utf-8')
            print(output)

        # Detect server type based on directories in /opt
        server_type = detect_server_type(channel)
        print(f"Server Type Detected: {server_type}")

        # Now switch to the command prompt for further interaction
        # Constructing the plink command for cmd.exe
        plink_command = f'plink.exe -ssh {username}@{host} -pw {password} -t "sudo su"'
        
        # Close the SSH session in Python
        channel.close()
        ssh.close()

        # Start a new cmd.exe window with the plink command
        subprocess.call(['cmd.exe', '/c', plink_command])

    except Exception as e:
        print(f"Failed to connect: {e}")

# Run the function
if __name__ == "__main__":
    ssh_to_server()





=================



import paramiko
import time
import subprocess

# Hard-coded username and password
USERNAME = "your_username"  # Replace with your SSH username
PASSWORD = "your_password"  # Replace with your SSH password

def detect_server_type(channel):
    """Detect the server type based on the presence of directories in /opt."""
    channel.send('cd /opt\n')
    time.sleep(1)
    channel.send('ls\n')
    time.sleep(1)
    
    server_types = ["springboot", "jboss", "splunk"]
    
    detected_type = "Regular"  # Default to regular

    if channel.recv_ready():
        output = channel.recv(1024).decode('utf-8').strip().splitlines()
        for line in output:
            for server_type in server_types:
                if server_type in line:
                    detected_type = server_type.capitalize()
                    break
            if detected_type != "Regular":
                break
    
    return detected_type

def ssh_to_server():
    # Prompt user for server IP address only
    host = input("Enter the server IP address: ")

    # Initialize the SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        # Connect to the server
        ssh.connect(host, username=USERNAME, password=PASSWORD)

        # Open an interactive shell session
        channel = ssh.invoke_shell()

        # Execute the sudo su command
        channel.send('sudo su\n')
        time.sleep(1)
        channel.send(PASSWORD + '\n')
        time.sleep(1)  # Give it some time to switch users

        # Read the output of the commands
        while channel.recv_ready():
            output = channel.recv(1024).decode('utf-8')
            print(output)

        # Detect server type based on directories in /opt
        server_type = detect_server_type(channel)
        print(f"Server Type Detected: {server_type}")

        # Now switch to the command prompt for further interaction
        # Constructing the plink command for cmd.exe
        plink_command = f'plink.exe -ssh {USERNAME}@{host} -pw {PASSWORD} -t "sudo su"'
        
        # Close the SSH session in Python
        channel.close()
        ssh.close()

        # Start a new cmd.exe window with the plink command
        subprocess.call(['cmd.exe', '/c', plink_command])

    except Exception as e:
        print(f"Failed to connect: {e}")

# Run the function
if __name__ == "__main__":
    ssh_to_server()
