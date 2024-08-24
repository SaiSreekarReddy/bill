import paramiko
import time
import os
from prompt_toolkit import PromptSession
from prompt_toolkit.completion import WordCompleter, PathCompleter

def detect_server_type(channel):
    """Detect the server type based on running processes."""
    server_types = {
        "Spring Boot": "springboot",
        "JBoss": "jboss",
        "Splunk": "splunk",
        "Regular": "None"
    }

    for server_name, keyword in server_types.items():
        channel.send(f"ps -ef | grep {keyword}\n")
        time.sleep(1)  # Wait for the command to execute
        if channel.recv_ready():
            output = channel.recv(1024).decode('utf-8')
            if keyword in output:
                return server_name
    
    return "Regular"  # Default to regular if no specific server is detected

def ssh_to_server():
    host = "your_vm_ip"  # Replace with your server's IP
    username = "your_username"  # Replace with your SSH username
    password = "your_password"  # Replace with your SSH password

    # Initialize the SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

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

    # Detect server type
    server_type = detect_server_type(channel)
    print(f"Server Type Detected: {server_type}")

    # Setup for tab completion
    path_completer = PathCompleter()
    session = PromptSession()

    # Interactive loop to keep the session open
    while True:
        try:
            # Input with tab-completion for file paths
            command = session.prompt("Enter command (type 'exit' to close): ", completer=path_completer)
        except KeyboardInterrupt:
            continue  # Handle Ctrl+C
        except EOFError:
            break  # Handle Ctrl+D

        if command.lower() == "exit":
            break

        channel.send(command + '\n')
        time.sleep(1)  # Wait for the command to execute

        while channel.recv_ready():
            output = channel.recv(1024).decode('utf-8')
            print(output)

    # Close the connection
    channel.close()
    ssh.close()

# Run the function
ssh_to_server()



========================


import paramiko
import time
import os
from prompt_toolkit import PromptSession
from prompt_toolkit.completion import WordCompleter, PathCompleter

def ssh_to_server():
    host = "your_vm_ip"  # Replace with your server's IP
    username = "your_username"  # Replace with your SSH username
    password = "your_password"  # Replace with your SSH password

    # Initialize the SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

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

    # Setup for tab completion
    path_completer = PathCompleter()
    session = PromptSession()

    # Interactive loop to keep the session open
    while True:
        try:
            # Input with tab-completion for file paths
            command = session.prompt("Enter command (type 'exit' to close): ", completer=path_completer)
        except KeyboardInterrupt:
            continue  # Handle Ctrl+C
        except EOFError:
            break  # Handle Ctrl+D

        if command.lower() == "exit":
            break

        channel.send(command + '\n')
        time.sleep(1)  # Wait for the command to execute

        while channel.recv_ready():
            output = channel.recv(1024).decode('utf-8')
            print(output)

    # Close the connection
    channel.close()
    ssh.close()

# Run the function
ssh_to_server()
