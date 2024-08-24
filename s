import paramiko
import time
import os
import glob
import readline

# Set of common shell commands
SHELL_COMMANDS = ['cd', 'ls', 'mkdir', 'rm', 'cp', 'mv', 'cat', 'echo', 'sudo', 'exit']

def complete_path(text, state):
    """Tab completion for paths and shell commands."""
    if state == 0:
        if text:
            # Complete file path
            self.matches = glob.glob(text + '*')
        else:
            # Complete shell command
            self.matches = SHELL_COMMANDS[:]
    try:
        return self.matches[state]
    except IndexError:
        return None

def detect_server_type(channel):
    """Detect the server type based on running processes."""
    server_types = {
        "Spring Boot": "springboot",
        "JBoss": "jboss",
        "Splunk": "splunk",
        "Regular": "None"
    }

    detected_types = []
    
    for server_name, keyword in server_types.items():
        channel.send(f"ps -ef | grep {keyword}\n")
        time.sleep(1)  # Wait for the command to execute
        if channel.recv_ready():
            output = channel.recv(1024).decode('utf-8')
            if output.count(keyword) > 1:
                detected_types.append(server_name)
    
    if detected_types:
        return ', '.join(detected_types)
    else:
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

    # Set up tab-completion
    readline.set_completer(complete_path)
    readline.parse_and_bind("tab: complete")

    # Interactive loop to keep the session open
    while True:
        try:
            # Input with tab-completion for file paths
            command = input("Enter command (type 'exit' to close): ")
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
